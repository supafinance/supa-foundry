// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {GelatoBytes} from "./GelatoBytes.sol";
import {Module, ModuleData} from "./Types.sol";
import {AutomateTaskCreator} from "./AutomateTaskCreator.sol";
import {IOpsProxy} from "./interfaces/IOpsProxy.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {SupaState} from "src/supa/SupaState.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ITaskCreator} from "src/gelato/interfaces/ITaskCreator.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title Task Creator for Supa Automations
contract TaskCreator is ITaskCreator, AutomateTaskCreator, Ownable, ERC20 {
    using GelatoBytes for bytes;
    using SafeERC20 for IERC20;

    /// @notice The address of the fee collector
    address public feeCollector;

    /// @notice The tiers for power purchase
    Tier[] public tiers;

    /// @notice The supa address
    SupaState public immutable supa;

    /// @notice The USDC address
    IERC20 public immutable usdc;

    /// @notice The deposit amount for task creation
    uint256 public depositAmount;
    /// @notice The power credits per execution
    uint256 public powerPerExecution;

    /// @notice Mapping of task owners
    /// @return taskOwner The owner of `taskId`
    mapping(bytes32 taskId => address taskOwner) public taskOwner;

    /// @notice Mapping of task deposit amounts
    /// @return depositAmount The deposit amount of `taskId`
    mapping(bytes32 taskId => uint256 depositAmount) public depositAmounts;

    /// @notice Mapping of task execution frequencies
    /// @return taskExecFrequency The execution frequency of `taskId`
    mapping(bytes32 taskId => uint256 taskExecFrequency) public taskExecFrequency;

    /// @notice Mapping of user's power data (power credits, lastUpdate, taskExecsPerSecond)
    mapping(address user => UserPowerData userPowerData) public userPowerData;

    mapping(address admin => bool isAllowed) public allowlistRole;
    mapping(string cid => bool isAllowed) public allowlistCid;

    AggregatorV3Interface public gasPriceFeed;

    /// @notice Reverts if called by any account that is not the task owner or the task owner's wallet owner
    modifier onlyTaskOwner(bytes32 taskId) {
        address _taskOwner = taskOwner[taskId];
        if (msg.sender != _taskOwner) {
            (address walletOwner,) = supa.wallets(_taskOwner);
            if (msg.sender != walletOwner) {
                revert NotTaskOwner();
            }
        }
        _;
    }

    /// @notice Reverts if called by any account that is not a supa wallet
    modifier onlySupaWallet() {
        (address owner,) = supa.wallets(msg.sender);
        if (owner == address(0)) {
            revert NotSupaWallet();
        }
        _;
    }

    modifier onlyAllowlistRole() {
        if (!allowlistRole[msg.sender]) {
            revert Unauthorized();
        }
        _;
    }

    /// @param _supa The address of the supa contract
    /// @param _automate The address of the automate contract
    /// @param _taskCreatorProxy The address of the task creator proxy
    constructor(address _supa, address _automate, address _taskCreatorProxy, address _usdc)
        AutomateTaskCreator(_automate, _taskCreatorProxy)
        ERC20("Supa Power Credits", "PWR")
    {
        if (_supa == address(0) || _usdc == address(0)) {
            revert AddressZero();
        }
        supa = SupaState(_supa);
        usdc = IERC20(_usdc);
    }

    /// @notice Purchase power credits
    /// @dev The amount of power credits purchased is calculated based on the amount of USDC sent
    /// @param user The user to purchase power for
    /// @param amount The amount of USDC to send
    function purchasePowerExactUsdc(address user, uint256 amount) external {
        uint256 powerCreditsToPurchase = calculatePowerPurchase(amount);

        _mint(user, powerCreditsToPurchase);

        // transfer USDC to the fee collector
        if (!usdc.transferFrom(msg.sender, feeCollector, amount)) {
            revert UsdcTransferFailed();
        }
        emit PowerPurchased(user, powerCreditsToPurchase, amount);
    }

    /// @notice Purchase power credits
    /// @dev The amount of USDC required is calculated based on the amount of power credits requested
    /// @param user The user to purchase power for
    /// @param powerCreditsToPurchase The amount of power credits to purchase
    function purchasePowerCredits(address user, uint256 powerCreditsToPurchase) external {
        // update power credits
        _mint(user, powerCreditsToPurchase);

        uint256 usdcAmount = calculateUsdcForPower(powerCreditsToPurchase);

        if (usdc.balanceOf(msg.sender) < usdcAmount) {
            revert InsufficientUsdcBalance(msg.sender);
        }

        if (!usdc.transferFrom(msg.sender, feeCollector, usdcAmount)) {
            revert UsdcTransferFailed();
        }
        emit PowerPurchased(user, powerCreditsToPurchase, usdcAmount);
    }

    /// @notice Admin function to increase a user's power credits
    /// @dev Can only be called by an allowlisted role
    function adminIncreasePower(address user, uint256 creditAmount) external onlyAllowlistRole {
        _mint(user, creditAmount);
        emit AdminPowerIncrease(user, creditAmount);
    }

    /// @notice Cancels the task with id `taskId`
    /// @dev Can only be called by the task owner
    /// @param taskId The id of the task to cancel
    function cancelTask(bytes32 taskId) external onlyTaskOwner(taskId) {
        _burnUsedCredits(msg.sender, taskId);
        _cancelTask(taskId);

        // refund the deposit
        _returnDeposit(taskId);
    }

    /// @notice Cancels the task with id `taskId` if the task is insolvent
    /// @dev revert if the task is solvent
    /// @param taskId The id of the task to cancel
    function cancelInsolventTask(bytes32 taskId) external {
        address taskOwner_ = taskOwner[taskId];

        if (!_burnUsedCredits(taskOwner_, taskId)) revert TaskNotInsolvent(taskId);

        _cancelTask(taskId);

        // award the deposit to the msg.sender
        _returnDeposit(taskId);
    }

    /// @notice Create an automation task
    /// @param automationId The id of the automation to execute
    /// @param operatorAddress The address of the operator
    /// @param cid The cid of the W3f to execute
    /// @param interval The interval at which to execute the task
    /// @param payGasWithCredits Whether to pay gas with credits
    /// @return taskId The id of the created task
    function createTask(uint256 automationId, address operatorAddress, string memory cid, uint256 interval, bool payGasWithCredits)
        public
        onlySupaWallet
        returns (bytes32 taskId)
    {
        if (!allowlistCid[cid]) {
            revert UnauthorizedCID(cid);
        }

        // Get power used since last update
        (address owner,) = supa.wallets(msg.sender);
        UserPowerData memory powerData = userPowerData[owner];
        uint256 cumulativeExecutions = (block.timestamp - powerData.lastUpdate) * powerData.taskExecsPerSecond; // adjusted by magnitude of 1 ether
        uint256 powerUsed = cumulativeExecutions * powerPerExecution / 1 ether;

        if (powerUsed > super.balanceOf(owner)) {
            revert InsufficientPower(owner);
        }

        // Get task execution frequency
        uint256 taskExecutionFrequency = (1 ether / interval) * 1000; // Approximate executions per second * 1 ether

        // Update user power data in storage
        userPowerData[owner] = UserPowerData({
            lastUpdate: block.timestamp,
            taskExecsPerSecond: powerData.taskExecsPerSecond + taskExecutionFrequency
        });

        ModuleData memory moduleData = ModuleData({modules: new Module[](3), args: new bytes[](3)});

        // Proxy module creates a dedicated proxy for this contract
        // ensures that only contract created tasks can call certain fuctions
        // restrict functions by using the onlyDedicatedMsgSender modifier
        moduleData.modules[0] = Module.PROXY; // 0
        moduleData.modules[1] = Module.WEB3_FUNCTION; // 4
        moduleData.modules[2] = Module.TRIGGER; // 5

        moduleData.args[0] = _proxyModuleArg();
        moduleData.args[1] = _web3FunctionModuleArg(
        // the CID is the hash of the W3f deployed on IPFS
            cid,
            // the arguments to the W3f are this contract's address
            // currently W3fs accept string, number, bool as arguments
            // thus we must convert the address to a string
            abi.encode(Strings.toHexString(msg.sender), Strings.toHexString(operatorAddress), payGasWithCredits)
        );
        moduleData.args[2] = _timeTriggerModuleArg(uint128(block.timestamp), uint128(interval));

        // execData passed to the proxy by the Automate contract
        // "batchExecuteCall" forwards calls from the proxy to this contract
        bytes memory execData = abi.encodeWithSelector(IOpsProxy.batchExecuteCall.selector);

        // decrement the user's power credits for
        // power used since update + deposit amount
        _burn(owner, powerUsed + depositAmount);

        // target address is this contracts dedicatedMsgSender proxy
        taskId = _createTask(
            dedicatedMsgSender,
            execData,
            moduleData,
            // zero address as fee token indicates
            // that the contract will use 1Balance for fee payment
            address(0)
        );

        // set the task variables after creating the taskId
        taskOwner[taskId] = msg.sender;
        taskExecFrequency[taskId] = taskExecutionFrequency;
        depositAmounts[taskId] = depositAmount;

        emit TaskCreated(taskId, msg.sender, automationId, cid);
    }

    /// @notice Create an automation task
    /// @param automationId The id of the automation
    /// @param operatorAddress The address of the operator
    /// @param cid The cid of the W3f to execute
    /// @param interval The interval at which to execute the task
    /// @param payGasWithCredits Whether to pay gas with credits
    /// @param admin The address of the signer
    /// @param signature The signature of the cid
    /// @return taskId The id of the created task
    function createTask(
        uint256 automationId,
        address operatorAddress,
        string memory cid,
        uint256 interval,
        bool payGasWithCredits,
        address admin,
        bytes calldata signature
    ) external onlySupaWallet returns (bytes32 taskId) {
        bytes32 digest = keccak256(bytes(cid));

        if (!allowlistRole[admin] || !SignatureChecker.isValidSignatureNow(admin, digest, signature)) {
            revert UnauthorizedCID(cid);
        }

        allowlistCid[cid] = true;

        taskId = createTask(automationId, operatorAddress, cid, interval, payGasWithCredits);
    }

    /// @notice Pay for gas with power credits
    /// @dev The amount of power credits used is calculated based on the amount of gas used
    /// @param gasAmount The amount of gas used
    function payGas(uint256 gasAmount) external onlySupaWallet {
        (, int256 price,,,) = gasPriceFeed.latestRoundData();
        if (price <= 0) {
            revert InvalidPrice();
        }

        uint256 creditAmount = gasAmount * uint256(price) * tiers[0].rate / 1e8 / 1e6;

        (address owner,) = supa.wallets(msg.sender);
        UserPowerData memory powerData = userPowerData[owner];
        uint256 cumulativeExecutions = (block.timestamp - powerData.lastUpdate) * powerData.taskExecsPerSecond; // adjusted by magnitude of 1 ether
        uint256 powerUsed = cumulativeExecutions * powerPerExecution / 1 ether;
        if (powerUsed > super.balanceOf(owner)) {
            revert("Not enough credits");
        }

        _burn(owner, creditAmount + powerUsed);

        emit GasPaidWithCredits(owner, gasAmount, creditAmount);
    }

    /// @notice Pay for gas with power credits
    /// @dev The amount of power credits used is calculated based on the amount of gas used
    /// @param gasAmount The amount of gas used
    function payGasNative(uint256 gasAmount) external payable onlySupaWallet {
        if (msg.value < gasAmount) {
            revert("Incorrect amount of ETH sent");
        }

        _transferEth(feeCollector, gasAmount);

        emit GasPaidNative(msg.sender, gasAmount);
    }

    function _transferEth(address to, uint256 amount) internal {
        (bool success,) = to.call{value: amount}("");
        if (!success) {
            revert("ETH transfer failed");
        }
    }

    /// @notice Fund executions by depositing to 1Balance
    /// @param token The token to deposit
    /// @param amount The amount to deposit
    function depositFunds1Balance(address token, uint256 amount) external payable {
        _depositFunds1Balance(amount, token, address(this));
    }

    /// @notice Set the tiers for power purchase
    /// @param newTiers The new tiers
    function setTiers(Tier[] memory newTiers) external onlyOwner {
        tiers = newTiers;
        emit FeeTiersSet(newTiers);
    }

    function setFeeCollector(address _feeCollector) external onlyOwner {
        feeCollector = _feeCollector;
        emit FeeCollectorSet(_feeCollector);
    }

    /// @notice Set the deposit amount for task creation
    /// @param _depositAmount The new deposit amount
    function setDepositAmount(uint256 _depositAmount) external onlyOwner {
        depositAmount = _depositAmount;
        emit DepositAmountSet(_depositAmount);
    }

    /// @notice Set the power credits per execution
    /// @param _powerPerExecution The new power credits per execution
    function setPowerPerExecution(uint256 _powerPerExecution) external onlyOwner {
        powerPerExecution = _powerPerExecution;
        emit PowerPerExecutionSet(_powerPerExecution);
    }

    function setGasPriceFeed(address priceFeed) external onlyOwner {
        gasPriceFeed = AggregatorV3Interface(priceFeed);
        emit GasPriceFeedSet(priceFeed);
    }

    function addAllowlistRole(address role) external onlyOwner {
        allowlistRole[role] = true;
    }

    function removeAllowlistRole(address role) external onlyOwner {
        allowlistRole[role] = false;
    }

    function addAllowlistCid(string memory cid) external onlyAllowlistRole {
        allowlistCid[cid] = true;
    }

    function removeAllowlistCid(string memory cid) external onlyAllowlistRole {
        allowlistCid[cid] = false;
    }

    function adminZeroTaskExecFrequency(address user) external onlyAllowlistRole {
        userPowerData[user].taskExecsPerSecond = 0;
    }

    /// @notice Get the current power credits for `user`
    /// @param user The user to get the power credits for
    /// @return remainingPowerCredits The remaining power credits for `user`
    function balanceOf(address user) public view override returns (uint256 remainingPowerCredits) {
        UserPowerData memory powerData = userPowerData[user];
        uint256 cumulativeExecutions = (block.timestamp - powerData.lastUpdate) * powerData.taskExecsPerSecond; // adjusted by magnitude of 1 ether
        uint256 powerUsed = cumulativeExecutions * powerPerExecution / 1 ether;

        remainingPowerCredits = super.balanceOf(user);
        if (powerUsed > remainingPowerCredits) {
            return 0;
        }

        return remainingPowerCredits - powerUsed;
    }

    function name() public view override returns (string memory) {
        return "Supa Power Credits";
    }

    function symbol() public view override returns (string memory) {
        return "PWR";
    }

    /// @notice Get the daily power burn for `user`
    /// @param user The user to get the daily power burn for
    /// @return dailyBurn The daily power burn for `user`
    function getUserDailyBurn(address user) external view returns (uint256 dailyBurn) {
        UserPowerData memory powerData = userPowerData[user];
        dailyBurn = powerData.taskExecsPerSecond * 1 days * powerPerExecution / 1 ether;
        return dailyBurn;
    }

    /// @notice Calculate the USDC required to purchase `powerAmount` power credits
    /// @param powerAmount The amount of power credits to purchase
    /// @return usdcRequired The amount of USDC required to purchase `powerAmount` power credits
    function calculateUsdcForPower(uint256 powerAmount) public view returns (uint256 usdcRequired) {
        if (tiers.length == 0) {
            revert TiersNotSet();
        }

        uint256 remainingPower = powerAmount;

        // Start from the highest tier and work down
        for (uint256 i = tiers.length; i > 0; i--) {
            uint256 index = i - 1;
            uint256 rate = tiers[index].rate;
            uint256 limit = tiers[index].limit;

            // If remainingPower/rate is greater than the limit, calculate accordingly
            if (remainingPower > limit) {
                usdcRequired += (remainingPower - limit) * rate / 1 ether;
                remainingPower = limit; // Assuming you want to set the remainingPower to limit
            }
        }

        // Any remaining power will be calculated at the lowest rate (tiers[0].rate)
        if (remainingPower > 0) {
            usdcRequired += remainingPower * tiers[0].rate / 1 ether;
        }

        return usdcRequired;
    }

    function calculatePowerPurchase(uint256 usdcAmount) public view returns (uint256 powerToPurchase) {
        uint256 rateToUse = 0;

        for (uint256 i = 0; i < tiers.length; i++) {
            if (usdcAmount > tiers[i].limit) {
                rateToUse = tiers[i].rate;
            } else {
                break;
            }
        }

        powerToPurchase = usdcAmount * rateToUse;
        return powerToPurchase;
    }

    /// @notice Get all power credit usdc tiers
    /// @return tiers The tiers
    function getAllTiers() public view returns (Tier[] memory) {
        return tiers;
    }

    function _returnDeposit(bytes32 taskId) internal {
        (address walletOwner,) = supa.wallets(msg.sender);
        if (walletOwner != address(0)) {
            _mint(walletOwner, depositAmounts[taskId]);
        } else {
            _mint(msg.sender, depositAmounts[taskId]);
        }
    }

    function _burnUsedCredits(address _taskOwner, bytes32 _taskId) internal returns (bool insolvent) {
        (address owner,) = supa.wallets(_taskOwner);
        UserPowerData memory powerData = userPowerData[owner];
        uint256 cumulativeExecutions = (block.timestamp - powerData.lastUpdate) * powerData.taskExecsPerSecond; // adjusted by magnitude of 1 ether
        uint256 powerUsed = cumulativeExecutions * powerPerExecution / 1 ether;
        if (powerUsed > super.balanceOf(owner)) {
            powerUsed = super.balanceOf(owner);
            insolvent = true;
        }

        _burn(owner, powerUsed);
        userPowerData[owner] = UserPowerData({
            lastUpdate: block.timestamp,
            taskExecsPerSecond: powerData.taskExecsPerSecond - taskExecFrequency[_taskId]
        });

        return insolvent;
    }

    function _onlyTaskOwner(bytes32 taskId) internal view {
        address _taskOwner = taskOwner[taskId];
        if (msg.sender != _taskOwner) {
            (address walletOwner,) = supa.wallets(_taskOwner);
            if (msg.sender != walletOwner) {
                revert NotTaskOwner();
            }
        }
    }
}
