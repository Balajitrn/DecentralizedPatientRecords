//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Healthcare {
    struct Doctor {
        uint id;
        string name;
        string qualification;
        string workPlace;
        bool exists;
    }

    struct Patient {
        string name;
        uint age;
        string[] diseases;
        bool exists;
    }

    struct Medicine {
        uint id;
        string name;
        uint expiryDate;
        uint dose;
        uint price;
    }
    uint private doctorIdCounter = 1; // A counter to generate unique IDs for doctors
    uint public patientIdCounter = 1; // A counter to generate unique IDs for patients

    mapping(uint => Doctor) public doctorsById; // A mapping of doctor IDs to Doctor structs
    mapping(address => uint) public doctorIds; // A mapping of doctor addresses to their respective IDs
    mapping(address => uint) public patientIds; // A mapping of patient address to thier respective IDs
    mapping(uint => Patient) public patientsById; // A mapping of patient IDs to Patient structs
    mapping(uint => address) public doctorAddresses; // A mapping of doctor IDs to their addresses
    mapping(uint => address) public patientAddresses; // A mapping of patient IDs to their addresses

    mapping(address => Doctor) public doctors;
    mapping(address => Patient) public patients;
    mapping(uint => Medicine) public medicines;
    mapping(address => uint[]) public patientMedicines;

    modifier doctorNotExists(address _doctorAddress) {
        require(!doctors[_doctorAddress].exists, "Doctor already exists.");
        _;
    }

    modifier patientNotExists(address _patientAddress) {
        require(!patients[_patientAddress].exists, "Patient already exists.");
        _;
    }

    modifier doctorExists(address _doctorAddress) {
        require(doctors[_doctorAddress].exists, "Doctor does not exist.");
        _;
    }

    modifier patientExists(address _patientAddress) {
        require(patients[_patientAddress].exists, "Patient does not exist.");
        _;
    }

    modifier medicineNotExists(uint _medicineId) {
        require(medicines[_medicineId].id != _medicineId, "Medicine already exists.");
        _;
    }

     function registerDoctor(
        string memory _name,
        string memory _qualification,
        string memory _workPlace
    ) public doctorNotExists(msg.sender) {
        uint _id = doctorIdCounter;
        Doctor memory newDoctor = Doctor(_id, _name, _qualification, _workPlace, true);
        doctors[msg.sender] = newDoctor;
        doctorsById[_id] = newDoctor;
        doctorIds[msg.sender] = _id;
        doctorAddresses[_id] = msg.sender;
        doctorIdCounter++;
    }


    function registerPatient(string memory _name, uint _age) public patientNotExists(msg.sender) {
        uint _id = patientIdCounter;
        Patient memory newPatient = Patient(_name, _age, new string[](0), true);
        patients[msg.sender] = newPatient;
        patientsById[_id] = newPatient;
        patientIds[msg.sender] = _id;
        patientAddresses[_id] = msg.sender;
        patientIdCounter++;
    }


    function addPatientDisease(string memory _disease) public patientExists(msg.sender) {
        patients[msg.sender].diseases.push(_disease);
    }

    function addMedicine(
        uint _id,
        string memory _name,
        uint _expiryDate,
        uint _dose,
        uint _price
    ) public medicineNotExists(_id) {
        medicines[_id] = Medicine(_id, _name, _expiryDate, _dose, _price);
    }

    function prescribeMedicine(uint _id, address _patient) public doctorExists(msg.sender) patientExists(_patient) {
        patientMedicines[_patient].push(_id);
    }

    function updatePatientAge(uint _age) public patientExists(msg.sender) {
        patients[msg.sender].age = _age;
    }

    function viewPatientData(address _patientAddress) public view patientExists(_patientAddress) returns (string memory, uint, string[] memory) {
        Patient memory patient = patients[_patientAddress];
        return (patient.name, patient.age, patient.diseases);
    }

    function viewMedicineDetails(uint _id) public view returns (string memory, uint, uint, uint) {
        Medicine memory medicine = medicines[_id];
        return (medicine.name, medicine.expiryDate, medicine.dose, medicine.price);
    }

    function viewPatientDataByDoctor(address _patientAddress) public view doctorExists(msg.sender) patientExists(_patientAddress) returns (string memory, uint, string[] memory) {
        return viewPatientData(_patientAddress);
    }

        function viewPrescribedMedicines(address _patientAddress) public view doctorExists(msg.sender) patientExists(_patientAddress) returns (uint[] memory) {
        return patientMedicines[_patientAddress];
    }

    function viewDoctorDetails(uint _id) public view returns (string memory, string memory, string memory) {
        Doctor memory doctor = doctorsById[_id];
        require(doctor.exists, "Doctor does not exist.");
        return (doctor.name, doctor.qualification, doctor.workPlace);
    }

    function getDoctorAddress(uint _id) public view returns (address) {
        require(doctorIds[doctorAddresses[_id]] == _id, "Doctor does not exist.");
        return doctorAddresses[_id];
    }

function getPatientAddress(uint _id) public view returns (address) {
    address patientAddress = patientAddresses[_id];
    require(patients[patientAddress].exists, "Patient does not exist.");
    return patientAddress;
}
}
