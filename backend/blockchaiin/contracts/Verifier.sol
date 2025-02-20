// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Pairing.sol"; 

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x302424f85a89296ea03ea0531b27dc96b3ed671b54056a9ea3077911d717c4df), uint256(0x1e0e50c6583375cb3ddee550334f03aa14b588248e3c88725952fdce0b045ba8));
        vk.beta = Pairing.G2Point([uint256(0x05efcd7db5ea5fa266cb3af1f0fce73b0b152fc78e18f0a025ac3d5c77f087a8), uint256(0x0181530efa68747cf53d46757064f859b9a6fdf9d0827361126d31003e6c219d)], [uint256(0x063f7e054cfe9ef6d52ec277ce955eb3872821801522d60e7d3004624c92d40f), uint256(0x0415a7b1e271d42a38fade4f783e46d48338ea2f1322d212b2ff7d4d3ee5108f)]);
        vk.gamma = Pairing.G2Point([uint256(0x0e1239df1752b4d70e00cc0e89229d8c52c9b92c9b778795b9a2124de9a6e4c2), uint256(0x27badc3fd2bdcedc3b0b80d1aae04417ecf8bf529e0eabb79e600c4858347451)], [uint256(0x17ef749e4adcd642f9a3fee7ea89d713dc9d72cd61d3d121a12784683cee2107), uint256(0x0b23e0412bfb5d517b5eb0e4e1b0b523722282de12227a84bd3edd883d12efa0)]);
        vk.delta = Pairing.G2Point([uint256(0x05184ad2bc99dae17ba81a51ebcea0db142f0053a701be09567276829b48472e), uint256(0x1d5dffcebe4e4400fd973abefbac8a4ea1cf460d71a88d90ffca97b4ab6f8f5e)], [uint256(0x1bc3c6970a44e14d737984bc4491d85876dc86f412b52a889e41c1399718624b), uint256(0x0f41fa5d3ffda4f6b06af816f129ddf969b99094456b136531a55ea6a85d6aab)]);
        vk.gamma_abc = new Pairing.G1Point[](3);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x005c488b40e655908fb615285e8a68693d994442757da7a7e548a6ff859027e6), uint256(0x2a4cc6c30de5eef5f9fd3dfbdac2568c64aa5ccd11a3572d219203f1d5489131));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x08c8e814712cb8d1ca1a71843dc64249ad081724b8b3f1f15f654c1ef8318e29), uint256(0x080e9f54cb136a3343008412cc240e204b197958972eca92f75ab76f0bf7172b));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x1f1c88941356daa45b408ca4d568949acff7b60df4b543a16261bb1713d2bcf4), uint256(0x0e4082edac6a3fd4cae589bafbcce9f58880a0319d09d53d60a13452ada47d7c));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[2] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](2);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
