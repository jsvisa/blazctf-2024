// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {MainchainGatewayV3} from "../src/mainchain/MainchainGatewayV3.sol";
import {Firewall} from "../src/onchain-firewall/contracts/Firewall.sol";
import {IFirewallPolicy} from "../src/onchain-firewall/contracts/interfaces/IFirewallPolicy.sol";

contract UltimateShell is IFirewallPolicy {
    function preExecution(address, address sender, bytes memory data, uint256 value) external {
        require(sender != 0x4Ab12E7CE31857Ee022f273e8580F73335a73c0B, "hack detected");
    }

    function postExecution(address, address sender, bytes memory data, uint256 value) external {}
}

contract Counter is Test {
    function setUp() public {
        vm.createSelectFork("http://localhost:38545", 20468579);
    }

    function test_increment() public {
        MainchainGatewayV3 bridge = MainchainGatewayV3(payable(0x64192819Ac13Ef72bF6b5AE239AC672B43a9AF08));
        MainchainGatewayV3 impl = new MainchainGatewayV3();
        Firewall firewall = new Firewall();

        vm.store(
            address(bridge),
            0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
            bytes32(uint256(uint160(address(this))))
        );

        address(bridge).call(abi.encodeWithSignature("upgradeTo(address)", address(impl)));
        vm.store(
            address(bridge),
            0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
            bytes32(uint256(uint160(address(this)) + 1))
        ); // workaround: admin can not fallback to impl

        address(bridge).call(abi.encodeWithSignature("initializeFirewall(address)", address(firewall)));

        address policy = address(new UltimateShell());
        firewall.setPolicyStatus(policy, true);
        firewall.addGlobalPolicy(address(bridge), policy);

        vm.prank(0x4Ab12E7CE31857Ee022f273e8580F73335a73c0B, 0x4Ab12E7CE31857Ee022f273e8580F73335a73c0B);
        (bool s,) = address(bridge).call(
            hex"4d0d66730000000000000000000000000000000000000000000000000000000000028ae700000000000000000000000000000000000000000000000000000000000000010000000000000000000000004ab12e7ce31857ee022f273e8580f73335a73c0b000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2000000000000000000000000000000000000000000000000000000000000000100000000000000000000000003e1f309d281b0af1a17ebb29e89136c05b67206000000000000000000000000c99a6a985ed2cac1ef41640596c5a5f9f4e19ef500000000000000000000000000000000000000000000000000000000000007e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d8a0f0ed69b4a1600000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000000000000000000000000000000000000000015000000000000000000000000000000000000000000000000000000000000001c897058e20ee89766649370ec29a43ddef9543d3923488eecaf6b04c26627b52223e9fc3d539039e06e741b84c9fe2ad263c27fef5b63e85e86f2206acc6b2f6e000000000000000000000000000000000000000000000000000000000000001c17ecacf630f45ee22f8dad0e57d5d22e95dda307da076a5f370c4fb90d274267179df04be58937918b9f02bb49276955e9df6265e46e54f3288538bd3c684399000000000000000000000000000000000000000000000000000000000000001b1c898d2ad402b7f988c8aa49588785aeee905e22871db19ffb35706e0a0cc6f063febce3c0f0a8572d728653c666fac7e136224a71b9bf1f2f4b3453fc6378cd000000000000000000000000000000000000000000000000000000000000001cba481bab790a26095e7661e9c0f5994efcccd1b2741b0a4f45fc5c95fc3e14556a3a05ba282673661255701d7d80aca6bf8bd40e9d0dcda805dbad68416c24f2000000000000000000000000000000000000000000000000000000000000001c723df7447eb6d3d23d2f5c8a90bf78b9e203670de28c0e29c32753e9869a6de87868a6d2a251948d634d5bb111bbc29ef9dc7451bca7ffb2d751755bef2f528e000000000000000000000000000000000000000000000000000000000000001b2138fc7863d879f08e61ffa5f8b0609c855db4c46f62c0ab53b2fdfd55c7476e3f61ce8490ec54c8db215948931ecaa4bf48f6e2dd638c7ab850640a90568d34000000000000000000000000000000000000000000000000000000000000001bea110b430c89ed2812fb74a2895abbf9c3b7cb68d3c5eaa2963e83045b92dc4a152319a4dbf65a8d9b92d42d13d8023e258dc11cdf5a5e3e162150c4488c8504000000000000000000000000000000000000000000000000000000000000001cb3efbcb300cd9345c3d5abc4f7f58d8377760c7d8a01bd0476d0b74e038134f75acbd5ed7d90c0191a571c70493a7e1613423c831f1aa4316bf12f375859bb83000000000000000000000000000000000000000000000000000000000000001cccbf4d51712a6e2895bcfa82f12a366742a903a1a58eaaa228d706567e807f62600ea089c5911ae1c6b8c4597cb7398765bdda4a38e0878dd11d8c75adb47eed000000000000000000000000000000000000000000000000000000000000001cfab7d86f0d12ef594b9d709baf10855c2cbc79d990e5439009ef0706ee01e1ac5a0207bd6bf6c0416e3003afbd04a4dcbf3de1999d076d0dcbf63cb4c2c1ff4d000000000000000000000000000000000000000000000000000000000000001b2e2ae00249dc8f16c53c1c06d20a6467710eb27409e8da6d7ee3bec8cbd3fc9330d6afbd38882af409ba63a9090260fdf1b8ce3cb9c47a779c21b12f439847b2000000000000000000000000000000000000000000000000000000000000001c254b9901ad0df9420579f6a246ac222ef80580864eabc0eec664b7b0361c443a1c3d59407ff5d6701a8a0963f8833a0ffb135c255ca1c9301587b059ebdd302f000000000000000000000000000000000000000000000000000000000000001c0424e472f971fc911af8bd12bf705406897f3f287091a4512807f9fd112b9dd16710c18f3e7b2da049f8305d6c379f6607f8d9c6209ab31493b1aeca0482fbc9000000000000000000000000000000000000000000000000000000000000001b282ff70596c2e611771ca767665c762704f4244c98be0c6b8f460a7ebcbd7d92097ab48c013e2d83a10c2a9c8d39a498457e86c6ba6c4acb92113572a1b13966000000000000000000000000000000000000000000000000000000000000001ca6c3af0550dd91a42eec66eac9f525ec1eb6a0b13b64aedfd94662cd8a6c0147254ecc4dae5cf31ef1ac9b9c43c6daa4c0b881f41e053925ebbf46fcef9b082e000000000000000000000000000000000000000000000000000000000000001b27566c371f7fafbba00783db6317de07a7ca9c0e1254e85df2f0ebd85860b2ac5b4cdb52ed993481359e329f810a6685eca156da701ce67529ba1176361a762d000000000000000000000000000000000000000000000000000000000000001c573dd4f363d5a8129b1aee9155f8fdd06bbb57768800aca4dac6fc5ac9c8560f7480b4fabc0e8a57339d81d3cf5ecbbf1fbbd129a0dbb2fb7aa8b74b17f73263000000000000000000000000000000000000000000000000000000000000001cffece14ccd9d2e4c3a94c6891e45b511a17f6643dade4958611a78ee4067f7ac0c3433106d837dc9633c700ea6d5cb4435219784e439e4075056df578c821800000000000000000000000000000000000000000000000000000000000000001be95d5f5b9954673562c8c9f9cee2818ccb2b6e7a6fdf43788cf83a19af8c156545cb7b009c2d7a304fe94a5ebd01192a7763804c727fa5ca2080805bbbe0a821000000000000000000000000000000000000000000000000000000000000001cd1d7f6fb08d459a8440c96ca5661ad28b12abb822c9764658b7d779d5af6ea43712596584b11f51026a8a811209214182b0dd0ebadebff7dcdc1d7192b8e5938000000000000000000000000000000000000000000000000000000000000001c5025f9771d277d4a17805d77d161c9594f34e718b9f0eb0bcf3b9e4e68f1e22715bd19d28be72f9d4024d43be3da8c0f494d484bf1ec913a6e4adc21575e7b64"
        );
        assertFalse(s);

        (s,) = address(bridge).call(
            hex"4d0d66730000000000000000000000000000000000000000000000000000000000028ae700000000000000000000000000000000000000000000000000000000000000010000000000000000000000004ab12e7ce31857ee022f273e8580f73335a73c0b000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2000000000000000000000000000000000000000000000000000000000000000100000000000000000000000003e1f309d281b0af1a17ebb29e89136c05b67206000000000000000000000000c99a6a985ed2cac1ef41640596c5a5f9f4e19ef500000000000000000000000000000000000000000000000000000000000007e4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d8a0f0ed69b4a1600000000000000000000000000000000000000000000000000000000000000001800000000000000000000000000000000000000000000000000000000000000015000000000000000000000000000000000000000000000000000000000000001c897058e20ee89766649370ec29a43ddef9543d3923488eecaf6b04c26627b52223e9fc3d539039e06e741b84c9fe2ad263c27fef5b63e85e86f2206acc6b2f6e000000000000000000000000000000000000000000000000000000000000001c17ecacf630f45ee22f8dad0e57d5d22e95dda307da076a5f370c4fb90d274267179df04be58937918b9f02bb49276955e9df6265e46e54f3288538bd3c684399000000000000000000000000000000000000000000000000000000000000001b1c898d2ad402b7f988c8aa49588785aeee905e22871db19ffb35706e0a0cc6f063febce3c0f0a8572d728653c666fac7e136224a71b9bf1f2f4b3453fc6378cd000000000000000000000000000000000000000000000000000000000000001cba481bab790a26095e7661e9c0f5994efcccd1b2741b0a4f45fc5c95fc3e14556a3a05ba282673661255701d7d80aca6bf8bd40e9d0dcda805dbad68416c24f2000000000000000000000000000000000000000000000000000000000000001c723df7447eb6d3d23d2f5c8a90bf78b9e203670de28c0e29c32753e9869a6de87868a6d2a251948d634d5bb111bbc29ef9dc7451bca7ffb2d751755bef2f528e000000000000000000000000000000000000000000000000000000000000001b2138fc7863d879f08e61ffa5f8b0609c855db4c46f62c0ab53b2fdfd55c7476e3f61ce8490ec54c8db215948931ecaa4bf48f6e2dd638c7ab850640a90568d34000000000000000000000000000000000000000000000000000000000000001bea110b430c89ed2812fb74a2895abbf9c3b7cb68d3c5eaa2963e83045b92dc4a152319a4dbf65a8d9b92d42d13d8023e258dc11cdf5a5e3e162150c4488c8504000000000000000000000000000000000000000000000000000000000000001cb3efbcb300cd9345c3d5abc4f7f58d8377760c7d8a01bd0476d0b74e038134f75acbd5ed7d90c0191a571c70493a7e1613423c831f1aa4316bf12f375859bb83000000000000000000000000000000000000000000000000000000000000001cccbf4d51712a6e2895bcfa82f12a366742a903a1a58eaaa228d706567e807f62600ea089c5911ae1c6b8c4597cb7398765bdda4a38e0878dd11d8c75adb47eed000000000000000000000000000000000000000000000000000000000000001cfab7d86f0d12ef594b9d709baf10855c2cbc79d990e5439009ef0706ee01e1ac5a0207bd6bf6c0416e3003afbd04a4dcbf3de1999d076d0dcbf63cb4c2c1ff4d000000000000000000000000000000000000000000000000000000000000001b2e2ae00249dc8f16c53c1c06d20a6467710eb27409e8da6d7ee3bec8cbd3fc9330d6afbd38882af409ba63a9090260fdf1b8ce3cb9c47a779c21b12f439847b2000000000000000000000000000000000000000000000000000000000000001c254b9901ad0df9420579f6a246ac222ef80580864eabc0eec664b7b0361c443a1c3d59407ff5d6701a8a0963f8833a0ffb135c255ca1c9301587b059ebdd302f000000000000000000000000000000000000000000000000000000000000001c0424e472f971fc911af8bd12bf705406897f3f287091a4512807f9fd112b9dd16710c18f3e7b2da049f8305d6c379f6607f8d9c6209ab31493b1aeca0482fbc9000000000000000000000000000000000000000000000000000000000000001b282ff70596c2e611771ca767665c762704f4244c98be0c6b8f460a7ebcbd7d92097ab48c013e2d83a10c2a9c8d39a498457e86c6ba6c4acb92113572a1b13966000000000000000000000000000000000000000000000000000000000000001ca6c3af0550dd91a42eec66eac9f525ec1eb6a0b13b64aedfd94662cd8a6c0147254ecc4dae5cf31ef1ac9b9c43c6daa4c0b881f41e053925ebbf46fcef9b082e000000000000000000000000000000000000000000000000000000000000001b27566c371f7fafbba00783db6317de07a7ca9c0e1254e85df2f0ebd85860b2ac5b4cdb52ed993481359e329f810a6685eca156da701ce67529ba1176361a762d000000000000000000000000000000000000000000000000000000000000001c573dd4f363d5a8129b1aee9155f8fdd06bbb57768800aca4dac6fc5ac9c8560f7480b4fabc0e8a57339d81d3cf5ecbbf1fbbd129a0dbb2fb7aa8b74b17f73263000000000000000000000000000000000000000000000000000000000000001cffece14ccd9d2e4c3a94c6891e45b511a17f6643dade4958611a78ee4067f7ac0c3433106d837dc9633c700ea6d5cb4435219784e439e4075056df578c821800000000000000000000000000000000000000000000000000000000000000001be95d5f5b9954673562c8c9f9cee2818ccb2b6e7a6fdf43788cf83a19af8c156545cb7b009c2d7a304fe94a5ebd01192a7763804c727fa5ca2080805bbbe0a821000000000000000000000000000000000000000000000000000000000000001cd1d7f6fb08d459a8440c96ca5661ad28b12abb822c9764658b7d779d5af6ea43712596584b11f51026a8a811209214182b0dd0ebadebff7dcdc1d7192b8e5938000000000000000000000000000000000000000000000000000000000000001c5025f9771d277d4a17805d77d161c9594f34e718b9f0eb0bcf3b9e4e68f1e22715bd19d28be72f9d4024d43be3da8c0f494d484bf1ec913a6e4adc21575e7b64"
        );
        assertTrue(s);
    }
}