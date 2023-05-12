// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract universityData {
    //universityId => universityName
    mapping(uint256 => string) public avilabelUniversity;
    mapping(uint256 => address) public universityOwner;
    uint256 idCcounter;
    //universityId => studentId => documentHash
    mapping(uint256 => mapping(uint256 => uint256))
        public universityStudentRecord;
    mapping(uint256 => uint256) public universityStudentCounter;
    mapping(uint256 => mapping(uint256 => string)) public studentData;

    function addUniversity(string memory name) public {
        avilabelUniversity[idCcounter + 1] = name;
        universityOwner[idCcounter + 1] = msg.sender;
        idCcounter = idCcounter + 1;
    }

    function addStudentData(
        uint256 _universityId,
        uint256 _studentId,
        string memory datahash
    ) public {
        require(
            universityOwner[_universityId] == msg.sender,
            "invalid university owner"
        );
        uint256 studentCount = universityStudentCounter[_universityId] + 1;
        studentData[_universityId][_studentId] = datahash;
        universityStudentCounter[_universityId] = studentCount;
        universityStudentRecord[_universityId][studentCount] = _studentId;
    }

    function getStudentData(uint256 _universityId, uint256 _studentId)
        public
        view
        returns (string memory)
    {
        return studentData[_universityId][_studentId];
    }

    function getStudentDocs(uint256 _universityId)
        public
        view
        returns (
            uint256[] memory,
            string[] memory,
            string memory,
            uint256
        )
    {
        uint256 totalDocuments = universityStudentCounter[_universityId];
        string memory universityName = avilabelUniversity[_universityId];
        uint256[] memory studentIds = new uint256[](totalDocuments);
        string[] memory datahashes = new string[](totalDocuments);
        for (uint256 i = 1; i <= totalDocuments; i++) {
            studentIds[i - 1] = universityStudentRecord[_universityId][i];
            datahashes[i - 1] = studentData[_universityId][studentIds[i - 1]];
        }
        return (studentIds, datahashes, universityName, totalDocuments);
    }
}
