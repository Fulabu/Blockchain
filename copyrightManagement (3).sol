// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CopyrightManagement {
    struct Copyright {
        uint256 id;
        string name;
        string description;
        string imageURL;
        uint256 price;
        bool isAdopted;
        uint256 purchaseTimestamp;
    }

    Copyright[] public copyrights;
    mapping(uint256 => address) public copyrightOwners;

    address public admin;

    event CopyrightPurchased(address indexed purchaser, uint256 copyrightId);
    event RefundIssued(address indexed recipient, uint256 copyrightId);
    event CopyrightVerified(address indexed verifier, uint256 copyrightId);
    event CopyrightCreated(uint256 copyrightId, address owner);
    event CopyrightEdited(uint256 copyrightId);
    event CopyrightDeleted(uint256 copyrightId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createCopyright(
        string memory _name,
        string memory _description,
        string memory _imageURL,
        uint256 _price
    ) public onlyAdmin {
        uint256 newId = copyrights.length;
        copyrights.push(
            Copyright(newId, _name, _description, _imageURL, _price, false, 0)
        );
        copyrightOwners[newId] = admin;
        emit CopyrightCreated(newId, admin);
    }

    function editCopyright(
        uint256 _copyrightId,
        string memory _name,
        string memory _description,
        string memory _imageURL,
        uint256 _price
    ) public onlyAdmin {
        require(_copyrightId < copyrights.length, "Copyright ID out of range");
        require(
            !copyrights[_copyrightId].isAdopted,
            "Cannot edit adopted copyright"
        );

        Copyright storage copyright = copyrights[_copyrightId];

        // Update fields
        copyright.name = _name;
        copyright.description = _description;
        copyright.imageURL = _imageURL;
        copyright.price = _price;

        emit CopyrightEdited(_copyrightId);
    }

    function deleteCopyright(uint256 _copyrightId) public onlyAdmin {
        require(_copyrightId < copyrights.length, "Copyright ID out of range");
        require(
            !copyrights[_copyrightId].isAdopted,
            "Cannot delete adopted copyright"
        );

        // Move the last element to the deleted position
        copyrights[_copyrightId] = copyrights[copyrights.length - 1];
        copyrights.pop();

        // Update the ID of the moved copyright if it's not the one we just deleted
        if (_copyrightId < copyrights.length) {
            copyrights[_copyrightId].id = _copyrightId;
        }

        emit CopyrightDeleted(_copyrightId);
    }

    function purchaseCopyright(uint256 _copyrightId) public payable {
        require(_copyrightId < copyrights.length, "Copyright ID out of range");
        Copyright storage copyright = copyrights[_copyrightId];
        require(!copyright.isAdopted, "Copyright already purchased");
        require(msg.value >= copyright.price, "Insufficient funds to purchase");

        copyright.isAdopted = true;
        copyright.purchaseTimestamp = block.timestamp;
        copyrightOwners[_copyrightId] = msg.sender;

        // Transfer funds to the admin
        payable(admin).transfer(msg.value);

        emit CopyrightPurchased(msg.sender, _copyrightId);
    }

    function requestRefund(uint256 _copyrightId) public {
        require(_copyrightId < copyrights.length, "Copyright ID out of range");
        require(
            copyrightOwners[_copyrightId] == msg.sender,
            "You do not own this copyright"
        );

        Copyright storage copyright = copyrights[_copyrightId];
        require(copyright.isAdopted, "Copyright has not been purchased");
        require(
            block.timestamp <= copyright.purchaseTimestamp + 30 seconds,
            "Refund period has expired"
        );

        // Direct refund from the admin to the buyer
        require(
            address(admin).balance >= copyright.price,
            "Admin does not have enough funds for refund"
        );
        (bool success, ) = msg.sender.call{value: copyright.price}("");
        require(success, "Refund failed");

        copyright.isAdopted = false;
        copyright.purchaseTimestamp = 0;
        copyrightOwners[_copyrightId] = address(0);

        emit RefundIssued(msg.sender, _copyrightId);
    }

    function verifyCopyright(uint256 _copyrightId) public view returns (bool) {
        require(_copyrightId < copyrights.length, "Copyright ID out of range");
        return copyrightOwners[_copyrightId] == msg.sender;
    }

    function getCopyright(
        uint256 _copyrightId
    )
        public
        view
        returns (
            uint256 id,
            string memory name,
            string memory description,
            string memory imageURL,
            uint256 price,
            bool isAdopted,
            uint256 purchaseTimestamp
        )
    {
        require(_copyrightId < copyrights.length, "Copyright ID out of range");
        Copyright memory copyright = copyrights[_copyrightId];
        return (
            copyright.id,
            copyright.name,
            copyright.description,
            copyright.imageURL,
            copyright.price,
            copyright.isAdopted,
            copyright.purchaseTimestamp
        );
    }

    function getAllCopyrights() public view returns (Copyright[] memory) {
        return copyrights;
    }

    // Fallback function to receive ETH
    receive() external payable {}
}
