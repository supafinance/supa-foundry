// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

enum Module {
    RESOLVER,
    TIME,
    PROXY,
    SINGLE_EXEC,
    WEB3_FUNCTION
}

struct ModuleData {
    Module[] modules;
    bytes[] args;
}

struct Gelato1BalanceParam {
    address sponsor;
    address feeToken;
    uint256 oneBalanceChainId;
    uint256 nativeToFeeTokenXRateNumerator;
    uint256 nativeToFeeTokenXRateDenominator;
    bytes32 correlationId;
}

interface IAutomate {
    function createTask(
        address execAddress,
        bytes calldata execDataOrSelector,
        ModuleData calldata moduleData,
        address feeToken
    ) external returns (bytes32 taskId);

    function cancelTask(bytes32 taskId) external;

    function exec(
        address taskCreator,
        address execAddress,
        bytes memory execData,
        ModuleData calldata moduleData,
        uint256 txFee,
        address feeToken,
        bool useTaskTreasuryFunds,
        bool revertOnFailure
    ) external;

    function exec1Balance(
        address taskCreator,
        address execAddress,
        bytes memory execData,
        ModuleData calldata moduleData,
        Gelato1BalanceParam calldata oneBalanceParam,
        bool revertOnFailure
    ) external;

    function getFeeDetails() external view returns (uint256, address);

    function gelato() external view returns (address payable);

    function taskModuleAddresses(Module) external view returns (address);

    function getTaskId(
        address taskCreator,
        address execAddress,
        bytes4 execSelector,
        ModuleData memory moduleData,
        address feeToken
    ) external pure returns (bytes32 taskId);
}

interface IProxyModule {
    function opsProxyFactory() external view returns (address);
}

interface IOpsProxyFactory {
    function getProxyOf(address account) external view returns (address, bool);
}

interface IGelato1Balance {
    function depositNative(address _sponsor) external payable;

    function depositToken(address _sponsor, address _token, uint256 _amount) external;
}
