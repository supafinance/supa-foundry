// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import {GelatoBytes} from "./GelatoBytes.sol";
import {Module, ModuleData} from "./Types.sol";
import {AutomateTaskCreator} from "./AutomateTaskCreator.sol";
import {IOpsProxy} from "./interfaces/IOpsProxy.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {SupaState} from "src/supa/SupaState.sol";

/// @title Task Creator for Supa Automations
contract TaskCreatorLogic is AutomateTaskCreator {
    using GelatoBytes for bytes;

    /// @notice Thrown when `msg.sender` is not the task owner
    error NotTaskOwner();

    /// @notice Thrown when `msg.sender` is not a supa wallet
    error NotSupaWallet();

    event TaskCreated(bytes32 indexed taskId, address indexed taskOwner, uint256 autoInstanceId, string cid);

    /// @notice The supa address
    SupaState public immutable supa;

    /// @notice Mapping of task owners
    /// @return taskOwner The owner of `taskId`
    mapping(bytes32 taskId => address taskOwner) public taskOwner;

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

    constructor(address _supa, address _automate, address _taskCreatorProxy) AutomateTaskCreator(_automate, _taskCreatorProxy, address(0)) {
        supa = SupaState(_supa);
    }

    /// @notice Cancels the task with id `taskId`
    /// @dev Can only be called by the task owner
    /// @param taskId The id of the task to cancel
    function cancelTask(bytes32 taskId) external onlyTaskOwner(taskId) {
        _cancelTask(taskId);
    }

    /// @notice Cancels the tasks with ids `taskIds`
    /// @dev Can only be called by the task owner
    /// @param taskIds The ids of the tasks to cancel
    function cancelTasks(bytes32[] memory taskIds) external {
        for (uint256 i = 0; i < taskIds.length; i++) {
            _onlyTaskOwner(taskIds[i]);
            _cancelTask(taskIds[i]);
        }
    }

    // todo: add function to cancel all tasks for a given user
    //    function cancelAllTasks() external {
    //        bytes32[] memory taskIds = _getTaskIds();
    //        for (uint256 i = 0; i < taskIds.length; i++) {
    //            _cancelTask(taskIds[i]);
    //        }
    //    }

    /// @notice Create an automation task
    /// @param autoInstanceId The id of the automation instance
    /// @param cid The cid of the W3f to execute
    /// @return taskId The id of the created task
    function createTask(uint256 autoInstanceId, string memory cid) external onlySupaWallet returns (bytes32 taskId) {
        ModuleData memory moduleData = ModuleData({modules: new Module[](2), args: new bytes[](2)});

        // Proxy module creates a dedicated proxy for this contract
        // ensures that only contract created tasks can call certain fuctions
        // restrict functions by using the onlyDedicatedMsgSender modifier
        moduleData.modules[0] = Module.PROXY;
        moduleData.modules[1] = Module.WEB3_FUNCTION;

        moduleData.args[0] = _proxyModuleArg();
        moduleData.args[1] = _web3FunctionModuleArg(
            // the CID is the hash of the W3f deployed on IPFS
            cid,
            // the arguments to the W3f are this contracts address
            // currently W3fs accept string, number, bool as arguments
            // thus we must convert the address to a string
            abi.encode(Strings.toHexString(msg.sender), autoInstanceId)
        );

        // execData passed to the proxy by the Automate contract
        // "batchExecuteCall" forwards calls from the proxy to this contract
        bytes memory execData = abi.encodeWithSelector(IOpsProxy.batchExecuteCall.selector);

        // target address is this contracts dedicatedMsgSender proxy
        taskId = _createTask(
            dedicatedMsgSender,
            execData,
            moduleData,
            // zero address as fee token indicates
            // that the contract will use 1Balance for fee payment
            address(0)
        );

        taskOwner[taskId] = msg.sender;

        emit TaskCreated(taskId, msg.sender, autoInstanceId, cid);
    }

    /// @notice Fund executions by depositing to 1Balance
    /// @param token The token to deposit
    /// @param amount The amount to deposit
    function depositFunds1Balance(address token, uint256 amount) external payable {
        _depositFunds1Balance(amount, token, address(this));
    }

    /// @notice Get the task id for a given automation instance id and cid
    /// @param autoInstanceId The id of the automation instance
    /// @param cid The cid of the W3f to execute
    /// @return taskId The id of the task
    function getTaskId(uint256 autoInstanceId, string memory cid) external view returns (bytes32 taskId) {
        ModuleData memory moduleData = ModuleData({modules: new Module[](2), args: new bytes[](2)});

        // Proxy module creates a dedicated proxy for this contract
        // ensures that only contract created tasks can call certain fuctions
        // restrict functions by using the onlyDedicatedMsgSender modifier
        moduleData.modules[0] = Module.PROXY;
        moduleData.modules[1] = Module.WEB3_FUNCTION;

        moduleData.args[0] = _proxyModuleArg();
        moduleData.args[1] = _web3FunctionModuleArg(
        // the CID is the hash of the W3f deployed on IPFS
            cid,
            // the arguments to the W3f are this contracts address
            // currently W3fs accept string, number, bool as arguments
            // thus we must convert the address to a string
            abi.encode(Strings.toHexString(msg.sender), autoInstanceId)
        );

        // execData passed to the proxy by the Automate contract
        // "batchExecuteCall" forwards calls from the proxy to this contract
        bytes memory execData = abi.encodeWithSelector(IOpsProxy.batchExecuteCall.selector);
        taskId = automate.getTaskId(
            msg.sender,
            dedicatedMsgSender,
            execData.memorySliceSelector(),
            moduleData,
            address(0)
        );
        return taskId;
    }

    /// @notice Get the task id for a given automation instance id and cid
    /// @param taskCreator The address of the task creator
    /// @param autoInstanceId The id of the automation instance
    /// @param cid The cid of the W3f to execute
    /// @return taskId The id of the task
    function getTaskId(address taskCreator, uint256 autoInstanceId, string memory cid) external view returns (bytes32 taskId) {
        ModuleData memory moduleData = ModuleData({modules: new Module[](2), args: new bytes[](2)});

        // Proxy module creates a dedicated proxy for this contract
        // ensures that only contract created tasks can call certain fuctions
        // restrict functions by using the onlyDedicatedMsgSender modifier
        moduleData.modules[0] = Module.PROXY;
        moduleData.modules[1] = Module.WEB3_FUNCTION;

        moduleData.args[0] = _proxyModuleArg();
        moduleData.args[1] = _web3FunctionModuleArg(
        // the CID is the hash of the W3f deployed on IPFS
            cid,
            // the arguments to the W3f are this contracts address
            // currently W3fs accept string, number, bool as arguments
            // thus we must convert the address to a string
            abi.encode(Strings.toHexString(msg.sender), autoInstanceId)
        );

        // execData passed to the proxy by the Automate contract
        // "batchExecuteCall" forwards calls from the proxy to this contract
        bytes memory execData = abi.encodeWithSelector(IOpsProxy.batchExecuteCall.selector);
        taskId = automate.getTaskId(
            taskCreator,
            dedicatedMsgSender,
            execData.memorySliceSelector(),
            moduleData,
            address(0)
        );
        return taskId;
    }

    function _onlyTaskOwner(bytes32 taskId) internal {
        address _taskOwner = taskOwner[taskId];
        if (msg.sender != _taskOwner) {
            (address walletOwner,) = supa.wallets(_taskOwner);
            if (msg.sender != walletOwner) {
                revert NotTaskOwner();
            }
        }
    }
}
