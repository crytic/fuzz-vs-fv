// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.11;

import "../Comet.sol";
import "../test/FaucetToken.sol";
import "../test/SimplePriceFeed.sol";

contract CometEchidnaHarness is Comet {
    constructor(Configuration memory config) Comet(config) {

    }

    function getTotalCollateral(address asset) public view returns (uint256) {
        return totalsCollateral[asset].totalSupplyAsset;
    }

    function getUserCollateral(address user, address asset, bool used) public view returns (uint256) {
        uint16 assetsIn = userBasic[user].assetsIn;
        Comet.AssetInfo memory assetInfo = getAssetInfoByAddress(asset);
        uint256 coll = 0;
        if (!used || isInAsset(assetsIn, assetInfo.offset)) {
            coll = userCollateral[user][asset].balance;
        }
        return coll;
    }
}

contract TestComet {
    CometEchidnaHarness public comet;
    Comet.AssetConfig[] public assets;

    constructor() {
        string[15] memory symbols = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O"];
        uint8[15] memory decimals = [6, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18];
        uint16[15] memory price = [1, 175, 3000, 200, 100, 250, 60, 1400, 1700, 800, 800, 800, 800, 800, 800];
        FaucetToken token;
        SimplePriceFeed feed;

        for (uint8 i=0; i<15; ++i) {
            token = new FaucetToken(0, symbols[i], decimals[i], symbols[i]);
            feed = new SimplePriceFeed(int256(int16(price[i])) * 1e8, 8);
            assets.push(Comet.AssetConfig({
                asset: address(token),
                priceFeed: address(feed),
                decimals: decimals[i],
                borrowCollateralFactor: (1e18) - 1,
                liquidateCollateralFactor: 1e18,
                liquidationFactor: 1e18,
                supplyCap: uint128(1000000 * (10**decimals[i]))
            }));

            token.allocateTo(address(0x10000), 1000000 * 10**decimals[i]);
            token.allocateTo(address(0x20000), 1000000 * 10**decimals[i]);
            token.allocateTo(address(0x30000), 1000000 * 10**decimals[i]);
        }
        
        Comet.Configuration memory config = Comet.Configuration({
            governor: address(0),
            pauseGuardian: address(0),
            baseToken: assets[0].asset,
            baseTokenPriceFeed: assets[0].priceFeed,
            kink: 8e17,
            perYearInterestRateBase: 5e15,
            perYearInterestRateSlopeLow: 1e17,
            perYearInterestRateSlopeHigh: 3e18,
            reserveRate: 1e17,
            trackingIndexScale: 1e15,
            baseTrackingSupplySpeed: 1e15,
            baseTrackingBorrowSpeed: 1e15,
            baseMinForRewards: 1e6,
            baseBorrowMin: 1e6,
            targetReserves: 0,
            assetConfigs: assets
        });

        comet = new CometEchidnaHarness(config);

        for (uint8 i=0; i<15; ++i) {
            token = FaucetToken(assets[i].asset);

            token.approveFrom(address(0x10000), address(comet), 1000000 * 10**decimals[i]);
            token.approveFrom(address(0x20000), address(comet), 1000000 * 10**decimals[i]);
            token.approveFrom(address(0x30000), address(comet), 1000000 * 10**decimals[i]);
        }
    }

    function sumUserCollateral(address asset, bool used) internal view returns (uint256) {
        address[4] memory users = [address(this), address(0x10000), address(0x20000), address(0x30000)];
        uint256 sum = 0;
        for (uint8 i = 0; i < users.length; ++i) {
            sum += comet.getUserCollateral(users[i], asset, used);
        }
        return sum;
    }

    function supply(uint256 assetId, uint256 amount) public {
        assetId = assetId % 15;
        address asset = assets[assetId].asset;
        FaucetToken(asset).allocateTo(address(this), amount);
        FaucetToken(asset).approve(address(comet), amount);
        comet.supply(asset, amount);
    }

    function transfer(uint256 assetId, address dst, uint256 amount) public {
        assetId = assetId % 15;
        address asset = assets[assetId].asset;
        supply(assetId, amount);
        comet.transfer(dst, asset, amount);
    }

    function echidna_used_collateral() public view returns (bool) {
        for (uint8 i = 0; i < assets.length; ++i) {
            address asset = assets[i].asset;
            uint256 userColl = sumUserCollateral(asset, true);
            uint256 totalColl = comet.getTotalCollateral(asset);
            if (userColl != totalColl) {
                return false;
            }
        }
        return true;
    }

    function echidna_total_collateral_per_asset() public view returns (bool) {
        for (uint8 i = 0; i < assets.length; ++i) {
            address asset = assets[i].asset;
            uint256 userColl = sumUserCollateral(asset, false);
            uint256 totalColl = comet.getTotalCollateral(asset);
            if (userColl != totalColl) {
                return false;
            }
        }
        return true;
    }
}