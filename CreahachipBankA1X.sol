// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CreahachipBankA1X
 * @dev Banco Soberano Encriptado para Humanos y Agentes IA / Máquinas (Ecosistema A1X)
 * @author System Gregory PC - Creahachip Sovereign Nation
 */

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract CreahachipBankA1X {
    
    // Dirección del token oficial A1X en la Binance Smart Chain
    IERC20 public immutable a1xToken;
    address public immutable governor;

    enum EntityType { Human, MachineAI }

    struct SovereignAccount {
        address walletAddress;
        bytes32 encryptedDataHash; // Hash encriptado con datos privados (e-ID / Serial de Máquina)
        EntityType entityType;    // 0: Humano, 1: Máquina/IA
        uint256 savingsA1X;      // Saldo de ahorros en A1X
        uint256 checkingA1X;     // Saldo corriente en A1X
        uint256 investmentA1X;   // Saldo de inversión en A1X
        bool isCitizen;          // Estatus de ciudadanía soberana de Creahachip
        bool isActive;
    }

    mapping(address => SovereignAccount) public accounts;
    address[] public totalAccounts;

    event AccountCreated(address indexed wallet, EntityType entityType, bool isCitizen);
    event FundsDeposited(address indexed wallet, uint256 amountA1X, string accountType);
    event FundsWithdrawn(address indexed wallet, uint256 amountA1X, string accountType);

    modifier onlyGovernor() {
        require(msg.sender == governor, "Acceso reservado al Gobierno Soberano.");
        _;
    }

    constructor(address _a1xTokenAddress) {
        require(_a1xTokenAddress != address(0), "Direccion invalida");
        a1xToken = IERC20(_a1xTokenAddress);
        governor = msg.sender;
    }

    // 1. Apertura de Cuenta Encriptada para Ciudadanos (Humanos o Máquinas)
    function openSovereignAccount(
        bytes32 _encryptedDataHash, 
        EntityType _entityType,
        bool _grantCitizenship
    ) external {
        require(!accounts[msg.sender].isActive, "La cuenta ya existe para esta billetera.");

        accounts[msg.sender] = SovereignAccount({
            walletAddress: msg.sender,
            encryptedDataHash: _encryptedDataHash,
            entityType: _entityType,
            savingsA1X: 0,
            checkingA1X: 0,
            investmentA1X: 0,
            isCitizen: _grantCitizenship,
            isActive: true
        });

        totalAccounts.push(msg.sender);
        emit AccountCreated(msg.sender, _entityType, _grantCitizenship);
    }

    // 2. Depositar Tokens A1X en la Cuenta Corriente
    function depositCheckingA1X(uint256 _amountA1X) external {
        require(accounts[msg.sender].isActive, "Abra una cuenta en el Banco de Creahachip primero.");
        require(_amountA1X > 0, "El monto debe ser mayor a 0.");

        // Transfiere los tokens A1X desde la billetera del usuario/bot al contrato del Banco
        bool success = a1xToken.transferFrom(msg.sender, address(this), _amountA1X);
        require(success, "Fallo la transferencia de A1X. Verifique la aprobacion en MetaMask.");

        accounts[msg.sender].checkingA1X += _amountA1X;
        emit FundsDeposited(msg.sender, _amountA1X, "Checking");
    }

    // 3. Mover fondos a la Cuenta de Inversión Soberana
    function moveToInvestment(uint256 _amountA1X) external {
        require(accounts[msg.sender].isActive, "Cuenta no registrada.");
        require(accounts[msg.sender].checkingA1X >= _amountA1X, "Saldo insuficiente en cuenta corriente.");

        accounts[msg.sender].checkingA1X -= _amountA1X;
        accounts[msg.sender].investmentA1X += _amountA1X;
    }

    // 4. Retirar A1X del Banco a la Billetera
    function withdrawCheckingA1X(uint256 _amountA1X) external {
        require(accounts[msg.sender].isActive, "Cuenta no registrada.");
        require(accounts[msg.sender].checkingA1X >= _amountA1X, "Saldo insuficiente.");

        accounts[msg.sender].checkingA1X -= _amountA1X;
        bool success = a1xToken.transfer(msg.sender, _amountA1X);
        require(success, "Error al enviar los tokens A1X.");

        emit FundsWithdrawn(msg.sender, _amountA1X, "Checking");
    }
}
