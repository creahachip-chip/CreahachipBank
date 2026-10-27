// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CreahachipBank
 * @dev Banco Soberano para Humanos y Agentes IA / Máquinas (Ecosistema A1X)
 * @author System Gregory PC - Creahachip Sovereign Nation
 */
contract CreahachipBank {
    
    // Tipos de entidades permitidas en el banco
    enum EntityType { Human, MachineAI }

    struct Account {
        address owner;
        string name;         // Nombre del humano o ID de la máquina (ej: Bodegalicia)
        EntityType entityType; // Humano o Máquina
        uint256 savingsBalance;   // Saldo de ahorros
        uint256 checkingBalance;  // Saldo cuenta corriente
        uint256 investmentBalance; // Saldo de inversión
        bool isActive;
    }

    // Mapeo de la dirección de la billetera a su cuenta bancaria
    mapping(address => Account) public accounts;
    
    // Lista de todas las direcciones con cuentas registradas
    address[] public accountHolders;

    // Eventos para rastreo en BscScan / Binance Web3
    event AccountOpened(address indexed owner, string name, EntityType entityType);
    event Deposited(address indexed owner, uint256 amount, string accountType);
    event Withdrawn(address indexed owner, uint256 amount, string accountType);

    // 1. Abrir cuenta (Funciona tanto para humanos como para bots/máquinas de forma autónoma)
    function openAccount(string memory _name, EntityType _entityType) external {
        require(!accounts[msg.sender].isActive, "La cuenta ya existe para esta billetera.");
        
        accounts[msg.sender] = Account({
            owner: msg.sender,
            name: _name,
            entityType: _entityType,
            savingsBalance: 0,
            checkingBalance: 0,
            investmentBalance: 0,
            isActive: true
        });

        accountHolders.push(msg.sender);
        emit AccountOpened(msg.sender, _name, _entityType);
    }

    // 2. Depositar fondos en la cuenta corriente
    function depositChecking() external payable {
        require(accounts[msg.sender].isActive, "Debe abrir una cuenta primero.");
        require(msg.value > 0, "El deposito debe ser mayor a cero.");
        
        accounts[msg.sender].checkingBalance += msg.value;
        emit Deposited(msg.sender, msg.value, "Checking");
    }

    // 3. Transferir fondos de Corriente a Ahorros
    function moveToSavings(uint256 _amount) external {
        require(accounts[msg.sender].isActive, "Cuenta no encontrada.");
        require(accounts[msg.sender].checkingBalance >= _amount, "Fondos insuficientes en cuenta corriente.");

        accounts[msg.sender].checkingBalance -= _amount;
        accounts[msg.sender].savingsBalance += _amount;
    }

    // 4. Invertir fondos
    function moveToInvestment(uint256 _amount) external {
        require(accounts[msg.sender].isActive, "Cuenta no encontrada.");
        require(accounts[msg.sender].checkingBalance >= _amount, "Fondos insuficientes.");

        accounts[msg.sender].checkingBalance -= _amount;
        accounts[msg.sender].investmentBalance += _amount;
    }

    // Consultar datos de cualquier cuenta (humano o máquina)
    function getAccountDetails(address _accountAddress) external view returns (
        string memory name,
        EntityType entityType,
        uint256 savings,
        uint256 checking,
        uint256 investment
    ) {
        Account memory acc = accounts[_accountAddress];
        require(acc.isActive, "La cuenta no existe.");
        return (acc.name, acc.entityType, acc.savingsBalance, acc.checkingBalance, acc.investmentBalance);
    }
}
