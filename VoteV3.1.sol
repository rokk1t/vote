// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

//# Owners
// [UA] Контракт для управління списком голів / [EN] Contract to manage the list of chairmen / [RU] Контракт для управления списком председателей
contract OwnerBlock {
  // [UA] Масив адрес голів / [EN] Array of chairman addresses / [RU] Массив адресов председателей
  address[] public owners;

  // TODO mapping
  //* Constructor
  // [UA] Конструктор для ініціалізації голів. Ігнорує нульові та повторювані адреси / [EN] Constructor to initialize chairmen. Ignores zero and duplicate addresses / [RU] Конструктор для инициализации владельцев. Игнорирует нулевые и повторяющиеся адреса
  constructor(address[] memory _owners) {
    bool invalid = false;
    
    // [EN] If the owners list at initialization is empty, set the message sender (deployer of the contract) as the sole chairman / [UA] Якщо список голів при ініціалізації порожній, встановлюємо відправника повідомлення (розгортальника контракту) як єдиного голову / [RU] Если список владельцев при инициализации пуст, устанавливаем отправителя сообщения (развертывающего контракт) как единственного председателя
    if(_owners.length == 0) {
      owners.push(msg.sender);
      return;
    }
    if(_owners.length == 1) {
      require(_owners[0] != address(0), "Invalid owner address");
      owners.push(_owners[0]);
      return;
    }

    for(uint i = 0; i < _owners.length; i++) {

      if(_owners[i] == address(0)) continue;

      for(uint j = 0; j < owners.length; j++) {
        if(owners[j] == _owners[i]) {
          invalid = true;
          break;
        }
      }
      
    if(invalid == true) continue;
    owners.push(_owners[i]);
    }
  }

  //* Modifiers
  // [UA] Модифікатор: перевіряє, чи є відправник головою / [EN] Modifier: checks if the sender is an chairman / [RU] Модификатор: проверяет, является ли отправитель председателем
  modifier onlyOwners() {
    require(oIsOwner(msg.sender) == true, "msg.sender is not an owner");
    _;
  }

  // [UA] Модифікатор: перевіряє, чи є адреса нульовою / [EN] Modifier: checks if the address is zero / [RU] Модификатор: проверяет, является ли адрес нулевым
  modifier notZeroAddress(address _addr) {
    require(_addr != address(0), "address(0)");
    _;
  }

  // [UA] Модифікатор: перевіряє, чи належить адреса списку голів / [EN] Modifier: checks if the address belongs to the chairman list / [RU] Модификатор: проверяет, принадлежит ли адрес списку председателей
  modifier isOwner(address _addr) {
    require(oIsOwner(_addr) == true, "Input address is not an owner");
    _;
  }

  // [UA] Модифікатор: перевіряє, чи не належить адреса списку голів / [EN] Modifier: checks if the address doesn't belong to the chairman list / [RU] Модификатор: проверяет, не принадлежит ли адрес списку председателей
  modifier isNotOwner(address _addr) {
    require(oIsOwner(_addr) == false, "Input address is an owner");
    _;
  }

  //* Functions
  //* Show
  // [UA] Повертає список всіх голів / [EN] Returns the list of all chairmen / [RU] Возвращает список всех председателей
  function oGetOwnerList() public view returns (address[] memory) {
    return owners;
  }

  //* Check
  // TODO mapping
  // [UA] Перевіряє, чи є вказана адреса головою / [EN] Checks if the given address is an chairman / [RU] Проверяет, является ли указанный адрес председателем
  function oIsOwner(address _addr) public view returns(bool) {
    for (uint i = 0; i < owners.length; i++) {
      if (owners[i] == _addr) {
        return true;
      }
    }
    return false;
  }
  // TODO mapping
  // [UA] Перевіряє, чи є всі вказані адреси головами / [EN] Checks if all the given addresses are chairmen / [RU] Проверяет, являются ли все указанные адреса председателями
  function oIsOwners(address[] memory _ownersToCheck) public view returns(bool) {
    for (uint i = 0; i < _ownersToCheck.length; i++) {
      if (!oIsOwner(_ownersToCheck[i])) {
        return false;
      }
    }
    return true;
  }

  //* Adds
  // [UA] Додає нову адресу до списку голів / [EN] Adds a new address to the chairman list / [RU] Добавляет новый адрес в список председателей
  function oAddOwner(address _addr) public onlyOwners notZeroAddress(_addr) isNotOwner(_addr) {
    owners.push(_addr);
  }

  // [UA] Додає декілька нових адрес до списку голів / [EN] Adds multiple new addresses to the chairman list / [RU] Добавляет несколько новых адресов в список председателей
  function oAddOwners(address[] memory _newOwners) public onlyOwners {
    require(_newOwners.length != 0, "_newOwners.length == 0");
    for (uint i = 0; i < _newOwners.length; i++) {
      require(_newOwners[i] != address(0), "_newOwners[i] == address(0)");
      require(!oIsOwner(_newOwners[i]), "_newOwners[i] is already an owner");
      owners.push(_newOwners[i]);
    }
  }

  //* Removals
  // [UA] Видаляє вказану адресу зі списку голів / [EN] Removes the given address from the chairman list / [RU] Удаляет указанный адрес из списка председателей
  function oRemoveOwner(address _addr) public onlyOwners isOwner(_addr) notZeroAddress(_addr) {
    for (uint i = 0; i < owners.length; i++) {
      if (owners[i] == _addr) {
        owners[i] = owners[owners.length - 1];
        owners.pop();
        return;
      }
    }
  }

  // [UA] Видаляє декілька адрес зі списку голів / [EN] Removes multiple addresses from the chairmen list / [RU] Удаляет несколько адресов из списка председателей
  function oRemoveOwners(address[] memory _addr) public onlyOwners {
    for (uint i = 0; i < _addr.length; i++) {
      for (uint j = 0; j < owners.length - 1; j++) {
        if(owners[j] == _addr[i]) {
          owners[j] = owners[owners.length-1];
          owners.pop();
          // [EN] If there is only one chairman left, stop the loop / [UA] Якщо залишився лише один голова, зупиняємо цикл / [RU] Если остался только один председатель, останавливаем цикл
          if(owners.length == 1) break;
        }
      }
    }
  }

  // [UA] Видаляє всіх голів, крім відправника повідомлення / [EN] Removes all chairmen except for the message sender / [RU] Удаляет всех председателей, кроме отправителя сообщения
  function oRemoveAllOwners() public onlyOwners {
    owners = new address[](1);
    owners[0] = msg.sender;
  }

  // [UA] Видаляє всіх голів, крім вказаної адреси / [EN] Removes all owners except for the given address / [RU] Удаляет всех председателей, кроме указанного адреса
  function oRemoveAllOwnersExcept(address _addr) public onlyOwners notZeroAddress(_addr) isOwner(_addr) {
    owners = new address[](1);
    owners[0] = _addr;
  }
}

//# RoundsProposalsWeights
// [UA] Контракт, що надає функціональність для управління раундами, пропозиціями та вагами голосів / [EN] Contract that provides functionality to manage rounds, bids, and vote weights / [RU] Контракт, предоставляющий функциональность для управления раундами, предложениями и весами голосов
abstract contract RoundProposaWeightBlock is OwnerBlock {
  //* structs
  // [UA] Структура, що описує пропозицію / [EN] Structure describing a proposal / [RU] Структура, описывающая предложение.
  struct Proposal {
    string name; // [UA] Назва пропозиції / [EN] Proposal name / [RU] Название предложения
    uint voteCounter; // [UA] Кількість голосів, що підтримують пропозицію / [EN] The number of votes supporting the proposal / [RU] Количество голосов, поддерживающих предложение.
  }

  // [UA] Структура, що описує вагу голосу / [EN] Structure describing the vote weight / [RU] Структура, описывающая вес голоса
  struct Weight {
    address voterAddress; // [UA] Адреса виборця / [EN] Voter address / [RU] Адрес избирателя
    uint weight; // [UA] Вага голосу / [EN] Vote weight / [RU] Вес голоса
  }

  // [UA] Структура, що описує раунд голосування / [EN] A structure describing the voting round / [RU] Структура, описывающая раунд голосования
  struct Round {
    Proposal[] proposals;  // [EA] List of proposals in this round / [UA] Список пропозицій у цьому раунді / [RU] Список предложений в этом раунде
    Weight[] weights;      // [UA] Список ваг у цьому раунді / [EN] List of weights in this round / [RU] Список весов в этом раунде
    bool timeStart;        // [UA] Статус раунду (почався чи ні) / [EN] Round status (started or not) / [RU] Статус раунда (начался или нет)
    uint timeFinish;       // [UA] Час завершення раунду / [EN] Round completion time / [RU] Время завершения раунда
  }

  //* State Variables
  // [UA] Змінна для зберігання всіх раундів голосування / [EN] Variable for storing all voting rounds / [RU] Переменная для хранения всех раундов голосования
  Round[] public rounds;

  //* Modifiers
  // [UA] Модифікатор для перевірки валідності індексу раунду / [EN] Modifier to check the validity of the round index / [RU] Модификатор для проверки валидности индекса раунда
  modifier roundValidIndex(uint _index) {
    require(_index < rounds.length, "Index out of bounds");
    _;
  }
}

//# Proposals
// [UA] Контракт, що надає функціональність для управління пропозиціями / [EN] Contract that provides functionality to manage proposals / [RU] Контракт, предоставляющий функциональность для управления предложениями
abstract contract ProposalBlock is OwnerBlock, RoundProposaWeightBlock {
  //* Modifiers
  // [UA] Модифікатор для перевірки валідності індексу пропозиції / [EN] Modifier to check the validity of the proposal index / [RU] Модификатор для проверки валидности индекса предложения
  modifier proposalValidIndex(uint __roundIndex, uint __proposalIndex) {
    require(__proposalIndex < rounds[__roundIndex].proposals.length, "Proposal index out of bounds");
    _;
  }

  //* Functions
  //* Viev
  // [UA] Функція для перегляду всіх пропозицій у вказаному раунді / [EN] Function to view all proposals in the specified round / [RU] Функция для просмотра всех предложений в указанном раунде
  function pfViewAllProposals(uint _roundIndex) public roundValidIndex(_roundIndex) view returns (Proposal[] memory) {
    return rounds[_roundIndex].proposals;
  }

  //* Adds
  // [UA] Функція для додавання одного варіанту для голосування у вказаний раунд / [EN] Function to add one voting option to the specified round / [RU] Функция для добавления одного варианта для голосования в указанный раунд
  function proposalsAddSingle(uint __roundIndex, string memory _proposalName) public onlyOwners roundValidIndex(__roundIndex) {
    rounds[__roundIndex].proposals.push(Proposal(_proposalName, 0));
  }
  
  // [UA] Функція для додавання декількох варіантів для голосування в вказаний раунд / [EN] Function to add multiple voting options to the specified round / [RU] Функция для добавления нескольких вариантов для голосования в указанный раунд
  function pfAddSomeProposals(uint _roundIndex, string[] memory _proposalNames) public onlyOwners roundValidIndex(_roundIndex) {
    Proposal[] storage targetProposals = rounds[_roundIndex].proposals;
    for (uint i = 0; i < _proposalNames.length; i++) {
      targetProposals.push(Proposal(_proposalNames[i], 0));
    }
  }

  //* Removes
  // [UA] Функція для видалення варіанту голосування в вказаному раунді / [EN] Function to delete a voting option in the specified round / [RU] Функция для удаления варианта голосования в указанном раунде
  function pfRemovesOneProposal(uint _roundIndex, uint _proposalIndex) public onlyOwners proposalValidIndex(_roundIndex, _proposalIndex) {
    Proposal[] storage targetProposals = rounds[_roundIndex].proposals;
    targetProposals[_proposalIndex] = targetProposals[targetProposals.length - 1];
    targetProposals.pop();
  }

  // [UA] Функція для видалення варіанту голосування у вказаному раунді зі збереженням індексів варіантів голосування / [EN] Function to delete a voting option in the specified round with saving the indexes of voting options / [RU] Функция для удаления варианта голосования в указанном раунде с сохранением индексов вариантов голосования
  function pfRemovesOneProposalKeepIndex(uint _roundIndex, uint _proposalIndex) public onlyOwners proposalValidIndex(_roundIndex, _proposalIndex) { // ! proposalsMinusSingleKeepIndex
    delete rounds[_roundIndex].proposals[_proposalIndex];
  }

  // [UA] Функція для очищення всіх варіантів голосування в вказаному раунді / [EN] Function to clear all voting options in the specified round / [RU] Функция для очистки всех вариантов голосования в указанном раунде
  function proposalsMinusAll(uint _roundIndex) public onlyOwners roundValidIndex(_roundIndex) { // ! pfRemovesAllProposals
    require(rounds[_roundIndex].proposals.length > 0, "No proposals to clear.");
    delete rounds[_roundIndex].proposals;
  }

  //* Changes
  // [UA] Функція для заміни варіанту голосування у вказаному раунді / [EN] Function to replace a voting option in the specified round / [RU] Функция для замены варианта голосования в указанном раунде
  function pfChange(uint _roundIndex, uint _proposalIndex, string memory _newName) public onlyOwners proposalValidIndex(_roundIndex, _proposalIndex) { // ! proposalsChange
    rounds[_roundIndex].proposals[_proposalIndex].name = _newName;
  }
}

//# Weighs
abstract contract WeightBlock is OwnerBlock, RoundProposaWeightBlock { 
  //* Modifiers
  modifier addressNotInWeights(uint _roundIndex, address _voter) { 
    bool exists = false;
    for (uint i = 0; i < rounds[_roundIndex].weights.length; i++) {
      if(rounds[_roundIndex].weights[i].voterAddress == _voter) {
        exists = true;
        break;
      }
    }
    require(!exists, "Address already exists in weights");
    _;
  }
  
  //* Functions
  //* View
  // [UA] Функція для перегляду ваги виборця по адресу в вказаному раунді / [EN] Function to view the weight of a voter by address in the specified round / [RU] Функция для просмотра веса избирателя по адресу в указанном раунде
  function wViewOneAddrWeight(uint _roundIndex, address _voter) public view roundValidIndex(_roundIndex) returns (uint) {
    for (uint i = 0; i < rounds[_roundIndex].weights.length; i++) {
      if (rounds[_roundIndex].weights[i].voterAddress == _voter) {
        return rounds[_roundIndex].weights[i].weight;
      }
    }
    return 0;
  }
  
  // [UA] Функція для перегляду всіх ваг у вказаному раунді / [EN] Function to view all weights in the specified round / [RU] Функция для просмотра всех весов в указанном раунде
  function wViewAllAddrWeightweights(uint _roundIndex) public view roundValidIndex(_roundIndex) returns (Weight[] memory) {
    return rounds[_roundIndex].weights;
  }

  //* Adds
  // [UA] Функція для додавання ваги виборцю у вказаному раунді / [EN] Function to add the weight of a voter by address to the specified round / [RU] Функция для добавления веса избирателя по адресу в указанный раунд
  function wAddAddressWeightNew (uint _roundIndex, address _voter, uint _Weight) public onlyOwners roundValidIndex(_roundIndex) {
    Weight[] storage weights = rounds[_roundIndex].weights;
    bool addressFound = false;
    for (uint i = 0; i < weights.length; i++) {
      if (weights[i].voterAddress == _voter) {
        if (_Weight >= 1) {
          weights[i].weight = _Weight;
        } else {
          // Удаляем избирателя с весом меньше 1
          weights[i] = weights[weights.length - 1];
         weights.pop();
        }
        addressFound = true;
        break; // Выход из цикла после обновления или удаления
      }
    }
    if (!addressFound && _Weight >= 1) {
      weights.push(Weight(_voter, _Weight));
    }
  }

  // [UA] Функція для додавання декількох ваг виборців по адресах у вказаний раунд / [EN] Function to add multiple weights of voters by addresses to the specified round / [RU] Функция для добавления нескольких весов избирателей по адресам в указанный раунд
  function wAddAddressWeights(uint _roundIndex, address[] memory _addresses, uint[] memory _weights) public onlyOwners roundValidIndex(_roundIndex) {
    require(_addresses.length == _weights.length, "Arrays must have the same length");
    Weight[] storage weights = rounds[_roundIndex].weights;
    for (uint i = 0; i < _addresses.length; i++) {
      bool addressFound = false;
      for (uint j = 0; j < weights.length; j++) {
        if (weights[j].voterAddress == _addresses[i]) {
          if (_weights[i] >= 1) {
            weights[j].weight = _weights[i];
          } else {
            weights[j] = weights[weights.length - 1];
            weights.pop();
          }
          addressFound = true;
          break;
        }
      }
      if (!addressFound && _weights[i] >= 1) {
        weights.push(Weight(_addresses[i], _weights[i]));
      }
    }
  }

  //* Removes
  // [UA] Функція для видалення ваги виборця по адресу у вказаному раунді / [EN] Function to delete the weight of a voter by address in the specified round / [RU] Функция для удаления веса избирателя по адресу в указанном раунде
  function wRevoveOneAddressWeight(uint _roundIndex, address _voter) public onlyOwners roundValidIndex(_roundIndex) {
    Weight[] storage weights = rounds[_roundIndex].weights;
    for (uint i = 0; i < weights.length; i++) {
      if(weights[i].voterAddress == _voter) {
        weights[i] = weights[weights.length - 1];
        weights.pop();
        return;
      }
    }
  }

  // [UA] Функція для очищення всіх ваг у вказаному раунді / [EN] Function to clear all weights in the specified round / [RU] Функция для очистки всех весов в указанном раунде
  function wRevoveAllAddressWeights(uint _roundIndex) public onlyOwners roundValidIndex(_roundIndex) {
    delete rounds[_roundIndex].weights;
  }
}

//# WeightsDelegate
abstract contract DelegateWeightBlock is OwnerBlock, RoundProposaWeightBlock, WeightBlock {
  /**
   * @dev [UA] Делегує вказану вагу від відправника до одержувача в вказаному раунді. / [EN] Delegates the specified weight from the sender to the recipient in the specified round. / [RU] Делегирует указанный вес от отправителя к получателю в указанном раунде.
   * @param _roundIndex [UA] Індекс раунду, в якому відбувається делегування. / [EN] The index of the round in which the delegation takes place. / [RU] Индекс раунда, в котором происходит делегирование.
   * @param _to [UA] Адреса одержувача. / [EN] Recipient address. / [RU] Адрес получателя.
   * @param _weight [UA] Вага, яку потрібно делегувати. / [EN] Weight to delegate. / [RU] Вес, который нужно делегировать.
   */
  function wDelegateWeight(uint _roundIndex, address _to, uint _weight) public roundValidIndex(_roundIndex) notZeroAddress(_to) {
    require(_to != msg.sender, "Cannot delegate to yourself"); // [UA] Неможливо делегувати самому собі / [EN] Cannot delegate to yourself / [RU] Невозможно делегировать самому себе
    require(_weight > 0, "Weight to delegate should be greater than zero"); // [UA] Вага, яку потрібно делегувати, повинна бути більше нуля / [EN] Weight to delegate should be greater than zero / [RU] Вес, который нужно делегировать, должен быть больше нуля

    Weight[] storage weights = rounds[_roundIndex].weights;
    
    uint senderWeight = 0;
    bool receiverFound = false;

    // [UA] Пошук відправника та одержувача в одному циклі / [EN] Search for the sender and recipient in one cycle / [RU] Поиск отправителя и получателя в одном цикле
    for (uint i = 0; i < weights.length; i++) {
      // [UA] Зменшення ваги відправника / [EN] Decrease the weight of the sender / [RU] Уменьшение веса отправителя
      if (weights[i].voterAddress == msg.sender) {
        senderWeight = weights[i].weight;
        require(senderWeight >= _weight, "Not enough weight to delegate");
        weights[i].weight -= _weight;
        if (weights[i].weight == 0) {
          // [UA] Видалення відправника, якщо його вага дорівнює нулю / [EN] Delete the sender if its weight is zero / [RU] Удаление отправителя, если его вес равен нулю
          weights[i] = weights[weights.length - 1];
          weights.pop();
        }
      }
      
      // [UA] Збільшення ваги одержувача / [EN] Increase the weight of the recipient / [RU] Увеличение веса получателя
      if (weights[i].voterAddress == _to) {
        weights[i].weight += _weight;
        receiverFound = true;
      }
    }

    // [UA] Перевірка на наявність достатнього ваги у відправника / [EN] Check for sufficient weight of the sender / [RU] Проверка на наличие достаточного веса у отправителя
    require(senderWeight >= _weight, "Sender not found or not enough weight");

    // [UA] Якщо одержувача не знайдено, додайте його з новою вагою / [EN] If the recipient is not found, add it with a new weight / [RU] Если получатель не найден, добавьте его с новым весом
    if (!receiverFound) {
      weights.push(Weight(_to, _weight));
    }
  }
}

//# Times
/**
 * @title TimeBlock
 * @dev [UA] Контракт для керуванням часом голосування / [EN] Contract for managing voting times. / [RU] Контракт для управления временем голосования.
 */
abstract contract TimeBlock is OwnerBlock, RoundProposaWeightBlock {
  //* Modifiers
  // [UA] Перевірка чи стартувало голосування / [EN] Check if voting has started / [RU] Проверка началось ли голосование
  modifier tmVoteHasStarted(uint _roundIndex) {
    require(rounds[_roundIndex].timeStart, "Voting has not started");
    _;
  }

  // [UA] Перевірка чи не стартувало голосування / [EN] Check if voting has not started / [RU] Проверка не началось ли голосование
  modifier tmVoteHasNotStarted(uint _roundIndex) {
    require(!rounds[_roundIndex].timeStart, "Voting has already started");
    _;
  }

  //* Functions
  /**
   * @dev [UA] Запускає голосування для вказаного раунду / [EN] Starts the voting for a specified round. / [RU] Запускает голосование для указанного раунда.
   * @param _roundIndex [UA] Індекс раунду / [EN] Index of the round. / [RU] Индекс раунда.
   * @param _votingDurationInSeconds [UA] Тривалість голосування в секундах / [EN] Voting duration in seconds. / [RU] Продолжительность голосования в секундах
   */
  function tfStartVoting(uint _roundIndex, uint _votingDurationInSeconds) public onlyOwners roundValidIndex(_roundIndex) {
    require(block.timestamp > rounds[_roundIndex].timeFinish, "A voting session is already in progress");
    require(!rounds[_roundIndex].timeStart, "Voting has already started");
    
    rounds[_roundIndex].timeStart = true;
    rounds[_roundIndex].timeFinish = block.timestamp + _votingDurationInSeconds;
  }

  /**
   * @dev [UA] Ручне завершення голосування для вказаного раунду / [EN] Manually finishes the voting for a specified round. / [RU] Ручное завершение голосования для указанного раунда.
   * @param _roundIndex [UA] Індекс раунду / [EN] Index of the round. / [RU] Индекс раунда.
   */
  function tfFinisVotinghManually(uint _roundIndex) public onlyOwners roundValidIndex(_roundIndex) {
    require(rounds[_roundIndex].timeStart == true, "Voting has not started yet");

    // [UA] Скидання змінних стану для цього раунду / [EN] Resetting state variables for this round / [RU] Сброс переменных состояния для этого раунда
    rounds[_roundIndex].timeStart = false;
    rounds[_roundIndex].timeFinish = 0;
  }
}

//# Round
/** 
 * @title RoundBlock
 * @dev [UA] Контракт для управління раундами голосування / [EN] Contract for managing voting rounds / [RU] Контракт для управления раундами голосования.
 */
abstract contract RoundBlock is OwnerBlock, RoundProposaWeightBlock {
  //* Functions
  /**
   * @notice [UA] Створює новий раунд голосування / [EN] Creates a new voting round / [RU] Создает новый раунд голосования.
   * @dev [UA] Створює новий раунд з заданими предложениями та вагами голосів для кожного виборця / [EN] Creates a new voting round with the specified proposals and voter weights / [RU] Создает новый раунд голосования с указанными предложениями и весами голосов для каждого избирателя.
   * @param _proposalNames [UA] Масив назв предложень / [EN] Array of proposal names / [RU] Массив названий предложений.
   * @param _addresses [UA] Масив адресів виборців / [EN] Array of voter addresses / [RU] Массив адресов избирателей.
   * @param _weights [UA] Масив ваг для виборців / [EN] Array of weights for voters / [RU] Массив весов для избирателей.
   */
  function rfCreateNewRouund(string[] memory _proposalNames, address[] memory _addresses, uint[] memory _weights) public onlyOwners {
    require(_addresses.length > 0, "No voters to add");
    require(_addresses.length == _weights.length, "Arrays must have the same length");
    require(_proposalNames.length > 1, "At least two proposals are required");

    // [UA] Ініціалізація нового раунду голосування / [EN] Initialization of a new voting round / [RU] Инициализация нового раунда голосования.
    rounds.push();
    uint newRoundIndex = rounds.length - 1;
    rounds[newRoundIndex].timeStart = false;
    rounds[newRoundIndex].timeFinish = 0;

    // [UA] Додавання пропозицій до раунду / [EN] Adding proposals to the round / [RU] Добавление предложений к раунду.
    for (uint i = 0; i < _proposalNames.length; i++) {
        rounds[newRoundIndex].proposals.push(Proposal(_proposalNames[i], 0));
    }

    // [UA] Встановлення ваг для виборців / [EN] Setting weights for voters / [RU] Установка весов для избирателей.
    for (uint i = 0; i < _addresses.length; i++) {
        rounds[newRoundIndex].weights.push(Weight(_addresses[i], _weights[i]));
    }
  }
}

//# Logics
/** 
 * @title LogicBlock
 * @dev [UA] Основний контракт для логіки голосування / [EN] Main contract for voting logic / [RU] Основной контракт для логики голосования
 */
contract LogicBlock is OwnerBlock, ProposalBlock, RoundBlock, TimeBlock, DelegateWeightBlock {
  uint public currentRoundIndex = 0;  // [UA] Індекс поточного активного раунду / [EN] Index of the current active round / [RU] Индекс текущего активного раунда

  /**
   * @dev [UA] Конструктор для ініціалізації власників / [EN] Constructor for owners initialization / [RU] Конструктор для инициализации владельцев
   * @param _owners [UA] Масив адрес власників / [EN] Array of owner addresses / [RU] Массив адресов владельцев
   */
  constructor(address[] memory _owners) OwnerBlock(_owners) {}

  /**
   * @notice [UA] Функція голосування / [EN] Voting function / [RU] Функция голосования
   * @dev [UA] Виборець може проголосувати лише один раз / [EN] A voter can vote only once / [RU] Избиратель может проголосовать только один раз
   * @param _roundIndex [UA] Індекс раунду / [EN] Round index / [RU] Индекс раунда
   * @param _proposalIndex [UA] Індекс пропозиції / [EN] Proposal index / [RU] Индекс предложения
   * @param _weightToUse [UA] Вага для голосування / [EN] Weight to use for voting / [RU] Вес для голосования
   */
  function vote(uint _roundIndex, uint _proposalIndex, uint _weightToUse) public proposalValidIndex(_roundIndex, _proposalIndex) tmVoteHasStarted(_roundIndex) {
    require(rounds[currentRoundIndex].timeFinish == 0 || block.timestamp < rounds[currentRoundIndex].timeFinish, "Voting period has ended"); 

    uint voterIndex;
    bool found = false;

    Proposal[] storage targetProposals = rounds[currentRoundIndex].proposals;
    Weight[] storage targetWeights = rounds[currentRoundIndex].weights;

    // [UA] Пошук виборця в масиві / [EN] Search for the voter in the array / [RU] Поиск избирателя в массиве
    for(uint i = 0; i < targetWeights.length; i++) {
      if(targetWeights[i].voterAddress == msg.sender) {
        voterIndex = i;
        found = true;
        break;
      }
    }

    require(found, "Voter not found"); 
    require(targetWeights[voterIndex].weight >= _weightToUse, "You do not have enough weight to vote");
    require(_weightToUse > 0, "Weight to use should be greater than zero"); 
    require(bytes(targetProposals[_proposalIndex].name).length != 0, "Cannot vote for a deleted proposal"); 

    targetProposals[_proposalIndex].voteCounter += _weightToUse;
    targetWeights[voterIndex].weight -= _weightToUse;
  }
}
