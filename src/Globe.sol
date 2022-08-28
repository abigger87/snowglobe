// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import { ERC721 } from "solmate/tokens/ERC721.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";

import { LogisticVRGDA } from "vrgdas/LogisticVRGDA.sol";
import { toDaysWadUnsafe, toWadUnsafe } from "vrgdas/utils/SignedWadMath.sol";

import { ISnowComputer } from "src/interfaces/ISnowComputer.sol";
import { ISnowV1Program } from "src/interfaces/ISnowV1Program.sol";

/// @title Globe
/// @author asnared <https://github.com/abigger87>
/// @notice A Simple Globe for the snow.computer
/// @notice Created using https://snow.computer/operators
/// @notice The Globe is a Logistic VRGDA ERC721 token with rights to set snow.computer sprites
contract Globe is ISnowV1Program, ERC721 {

  /// ##################### CUSTOMS #####################

  /// @notice Emitted when a new sprite is added to the globe
  event PutMeInCoach(address indexed from, uint8 spriteIndex, uint256 spriteValue);

  /// @notice Emitted when the program is run
  event FuckItWeBall(address indexed from, uint8 indexed spriteIndex, uint256 spriteValue);

  /// @notice Thrown if the msg sender is not a token hodler
  error BallersOnly();

  /// @notice Thrown if the msg value was not high enough
  error InsufficientPayment();

  /// ##################### STORAGE #####################

  /// @notice The next token id
  uint256 public totalSupply;

  /// @notice The sprite index
  uint8 public spriteIndex;

  /// @notice The sprite value
  uint256 public spriteValue;

  /// @notice The maximum supply of globes
  uint256 public constant MAX_SUPPLY = 256;

  /// @notice The base URI for the snow computer
  string public constant BASE_URI = "https://snow.computer/api/v1/token/";

  /// ################### CONSTRUCTOR ###################

  constructor()
    ERC721("Globe", "GLOBE")
    LogisticVRGDA(69.42e18, 0.31e18, toWadUnsafe(MAX_SUPPLY), 0.1e18)
  {}

  /// @notice Allows a token owner to set the sprites
  modifier baller {
    if (balanceOf[msg.sender] == 0) revert BallersOnly();
    _;
  }

  /// ################ CORE GLOBE LOGIC #################

  /// @notice Allows any baller to set the new sprite index and value
  /// @param index The sprite index
  /// @param value The sprite value
  function set(uint8 index, uint256 value) public baller {
    spriteIndex = index;
    spriteValue = value;
    emit PutMeInCoach(msg.sender, index, value);
  }

  /// @notice Allows any baller to run the program
  function run() public baller {
    // cache the index and value
    uint8 index = spriteIndex;
    uint256 value = spriteValue;
    SNOW.storeProgram(msg.sender, address(this));
    emit FuckItWeBall(msg.sender, index, value);
  }


  /// ################### ERC721 LOGIC ##################

  /// @notice Returns the token uri for a given token id
  /// @param id The token id
  /// @return The token uri
  function tokenURI(uint256 id) public pure virtual override returns (string memory) {
    return string(abi.encodePacked(BASE_URI, id.toString()));
  }

  /// @notice Mints a new Globe token
  /// @dev supply limits checked by getVRGDAPrice
  /// @return mintedId the id of the newly minted token
  function mint() external payable returns (uint256 mintedId) {
    uint256 price = getVRGDAPrice(toDaysWadUnsafe(block.timestamp), mintedId = totalSold++);

    if (msg.value <= MIN_PRICE) revert InsufficientPayment();
    _mint(msg.sender, mintedId);

    unchecked {
        SafeTransferLib.safeTransferETH(msg.sender, msg.value - price);
    }
  }

  /// ############### SNOW COMPUTER LOGIC ###############

  function name() external pure returns (string memory) {
    return "Globe";
  }

  function run(uint256[64] memory canvas, uint8 lastIndex)
    external
    returns (uint8 index, uint256 value)
  {
    uint256[2] memory sprites = [
        0x000003c004200bd01008281427e4300c281427e410080bd0042003c000000000
    ];

    if (canvas[61] != sprites[1]) {
        return (61, sprites[1]);
    } else if (canvas[52] != sprites[0]) {
        return (52, sprites[0]);
    } else if (canvas[43] != sprites[0]) {
        return (43, sprites[0]);
    }
  }
}