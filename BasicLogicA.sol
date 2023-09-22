// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
contract OwnerBlock { // TODO OwnerBlock
  address public owner; // Владелец // ! owner

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Sender is not the owner.");
    _;
  }
}


contract ProposalsBlock is OwnerBlock { // TODO ProposalBlock
  // structs
  // Структура "Вариант голосования"
  struct Proposal {
    string name;
    uint voteCounter;
  }

  // state variables
  Proposal[] public proposals; // Массив вариантов голосования. предложение // ! proposals

  // modifiers
  // modifier для проверки валидности индекса варианта голосования
  modifier proposalValidIndex(uint _index) {
    require(_index < proposals.length, "Index out of bounds");
    _;
  }

  // functions
  // function see[all] для просмотра всех вариантов голосования
  function proposalsGetAll() public view returns (Proposal[] memory) { // ! proposalsGetAll
  return proposals;
  }

  // functions for managing proposals
  // function add[] для добавления нескольких вариантов голосования
  function proposalsAddMultiple(string[] memory _proposalNames) public onlyOwner { // ! proposalsAddMultiple
    for (uint i = 0; i < _proposalNames.length; i++) {
      proposals.push(Proposal(_proposalNames[i],0));
    }
  }
  
  // function add для добавление одного варианта для голосования
  function proposalsAddSingle(string memory _proposalName) public onlyOwner { // ! proposalsAddSingle
    proposals.push(Proposal(_proposalName, 0));
  }

  // function minus[all] для очистки всех вариантов голосования
  function proposalsMinusAll() public onlyOwner { // ! proposalsMinusAll
    require(proposals.length > 0, "No proposals to clear.");
    delete proposals;
  }

  // function minus для удаления варианта голосования
  function proposalsMinusSingle(uint _index) public onlyOwner proposalValidIndex(_index) { // ! proposalsMinusSingle
    proposals[_index] = proposals[proposals.length - 1]; // Move the last element to the index to delete
    proposals.pop(); // Remove the last element
  }

  // function minus для удаления варианта голосования с сохранением индексов вариантов голосования
  function proposalsMinusSingleKeepIndex(uint _index) public onlyOwner proposalValidIndex(_index) { // ! proposalsMinusSingleKeepIndex
    delete proposals[_index];
  }

  // function change для замены варианта голосования
  function proposalsChange(uint _index, string memory _newName) public onlyOwner proposalValidIndex(_index) { // ! proposalsChange
    require(_index < proposals.length, "Index out of bounds.");
    proposals[_index].name = _newName;
  }
}


contract WeightBlock is OwnerBlock { // TODO WeightBlock
  // structs
  struct Weight {
      address voterAddress;
      uint weight;
  }

  // state variables
  Weight[] public weights; // ! weights

  // functions
  // function see[] для просмотра всех весов
  function weightsSeeAll() public view returns (Weight[] memory) { // ! weightsSeeAll
    return weights;
  }

  function weightsSeeOne(address _voter) public view returns (uint) { // ! weightsSeeOne
    for (uint i = 0; i < weights.length; i++) {
      if (weights[i].voterAddress == _voter) {
        return weights[i].weight;
      }
    }
    return 0;
  }

  // functions for managing weights
  // function add[] для добавления array весов
  function weightsAddMultiple(address[] memory _addresses, uint[] memory _weights) public onlyOwner { // ! weightsAddMultiple
    require(_addresses.length == weights.length, "Arrays must have the same length");
    
    for (uint i = 0; i < _addresses.length; i++) {
      if (_weights[i] > 0) {
        weights.push(Weight(_addresses[i], _weights[i]));
      }
    }
  }

  // function add для добавления одного веса
  function weightsAddSingle(address _voter, uint _newWeight) public onlyOwner { // ! weightsAddSingle
      for (uint i = 0; i < weights.length; i++) {
          if (weights[i].voterAddress == _voter) {
              if (_newWeight >= 1) {
                  weights[i].weight = _newWeight;
              } else {
                  // Удаляем избирателя с весом меньше 1
                  weights[i] = weights[weights.length - 1];
                  weights.pop();
              }
              return;
          }
      }
      
      if (_newWeight >= 1) {
          weights.push(Weight(_voter, _newWeight));
      }
  }

  function weightsMinusAll() public onlyOwner { // ! weightsMinusAll
      delete weights;
  }

  function weightsMinusSingle(address _voter) public onlyOwner { // ! weightsMinusSingle
    for (uint i = 0; i < weights.length; i++) {
      if (weights[i].voterAddress == _voter) {
        weights[i] = weights[weights.length - 1];
        weights.pop();
        return;
      }
    }
  }
}



contract DelegateWeightBlock is WeightBlock { // TODO DelegateWeightBlock
  // Пересылать голоса можно на любой адрес, кроме address(0).
  function delegateWeight(address _to, uint _weight) public { // ! delegateWeight
    require(_to != msg.sender, "Cannot delegate to yourself"); // Нельзя делегировать себе
    require(_weight > 0, "Weight to delegate should be greater than zero"); // Вес должен быть больше нуля
    require(weights.length != 0, "No voters to delegate from"); // Нет избирателей для делегирования
    require(_weight <= weightsSeeOne(msg.sender), "Not enough weight to delegate"); // Недостаточно веса для делегирования

    for (uint i = 0; i < weights.length; i++) {
      if (weights[i].voterAddress == msg.sender) {
        weights[i].weight -= _weight;

        // Поиск получателя и увеличение его веса
        for (uint j = 0; j < weights.length; j++) {
          if (weights[j].voterAddress == _to) {
            weights[j].weight += _weight;
            return;
          }
        }

        // Если получатель не найден, добавляем его
        weights.push(Weight(_to, _weight));
        return;
      }
    // Если цикл завершается и функция не возвращается, отправитель не найден
    revert("Sender not found");
    }
  }
}



contract LogicABlock is OwnerBlock, ProposalsBlock, WeightBlock { // TODO LogicABlock
  // state variables
  uint public aVotingEndTime = 0; // Время окончания голосования // !aVotingEndTime

  // State variable to track if voting has started
  bool public aVotingStarted = false; // ! aVotingStarted

  // Функция для начала голосования. Принимает продолжительность голосования в секундах
  function aStartVoting(uint _votingDurationInSeconds) public onlyOwner { // ! aStartVoting
    require(block.timestamp >= aVotingEndTime, "A voting session is already in progress or has ended");
    require(!aVotingStarted, "Voting has already started");

    aVotingStarted = true;
    aVotingEndTime = block.timestamp + _votingDurationInSeconds;
  }

  // Основная логика голосования
  function aVote(uint _proposalIndex, uint _weightToUse) public proposalValidIndex(_proposalIndex) { // ! aVote
    uint voterIndex;
    bool found = false;

    // Поиск голосующего в массиве
    for(uint i = 0; i < weights.length; i++) {
      if(weights[i].voterAddress == msg.sender) {
        voterIndex = i;
        found = true;
        break;
      }
    }

    require(found, "Voter not found");
    require(weights[voterIndex].weight >= _weightToUse, "You do not have enough weight to vote");
    require(_weightToUse > 0, "Weight to use should be greater than zero");
    require(bytes(proposals[_proposalIndex].name).length != 0, "Cannot vote for a deleted proposal");
    require(block.timestamp < aVotingEndTime, "Voting period has ended");
    require(aVotingStarted == true, "Voting has not started");

    // Учет веса избирателя при голосовании
    proposals[_proposalIndex].voteCounter += _weightToUse;

    // Списание веса после голосования
    weights[voterIndex].weight -= _weightToUse;
  }
}
