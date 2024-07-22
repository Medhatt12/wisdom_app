import '../models/scenario.dart';

final List<Scenario> story = [
  Scenario(
    text:
        'In this game, you will go on a journey of a day in the life of someone and you will be able to switch perspective between them and their partner.',
    choices: [
      Choice(text: 'Start Game', nextScenarioId: 1),
    ],
    image: 'assets/images/scenario1.png',
  ),
  Scenario(
    text:
        'You wake up early, feeling the weight of the important presentation you have today. You decide not to wake your partner, wanting them to get some extra sleep. You quietly get ready and leave for work without saying happy anniversary.',
    choices: [
      Choice(
          text:
              'Feel guilty for not saying anything but push the thought aside.',
          nextScenarioId: 2),
      Choice(
          text: 'Promise yourself to make it up to them later.',
          nextScenarioId: 2),
      Choice(
          text: 'Completely forget about the anniversary due to stress.',
          nextScenarioId: 2),
    ],
    perspectiveSwitch: 'Switch Perspective',
    perspectiveText:
        'You wake up and realize your partner has already left. It\'s your anniversary, and you feel a bit disappointed they didn\'t wake you up to celebrate. You decide to send them a good morning text, hoping for a loving reply.',
    image: 'assets/images/scenario2.png',
  ),
  Scenario(
    text:
        'You receive a morning text from your partner while preparing for your presentation. You\'re stressed and focused on work. How do you respond?',
    choices: [
      Choice(
          text:
              'Send a brief reply, "Good morning, I\'m really busy with work."',
          nextScenarioId: 3),
      Choice(
          text:
              'Send a distracted reply, "Morning, busy preparing for the presentation."',
          nextScenarioId: 3),
      Choice(
          text:
              'Send a loving reply, but with a work-focused undertone, "Good morning, love you, busy with the presentation."',
          nextScenarioId: 3),
    ],
    perspectiveSwitch: 'Switch Perspective',
    perspectiveText:
        'You read your partner\'s reply and feel a mix of emotions. They didn\'t mention the anniversary, which makes you feel neglected.',
    image: 'assets/images/scenario3.png',
  ),
  Scenario(
    text:
        'The presentation at work is intense, and you face unexpected challenges. You\'re stressed and anxious. How do you handle the situation?',
    choices: [
      Choice(
          text: 'Push through the stress, determined to succeed.',
          nextScenarioId: 4),
      Choice(
          text: 'Take a moment to think about your partner’s encouragement.',
          nextScenarioId: 4),
      Choice(
          text: 'Call your partner for support during a break.',
          nextScenarioId: 4),
    ],
    perspectiveSwitch: 'Switch Perspective',
    perspectiveText:
        'You know your partner is facing a big challenge today. How do you support them from afar?',
    image: 'assets/images/scenario4.png',
  ),
  Scenario(
    text:
        'After the presentation, a conflict arises with a colleague. You feel stressed and upset. What do you do?',
    choices: [
      Choice(
          text: 'Confront the colleague, trying to resolve the issue.',
          nextScenarioId: 5),
      Choice(
          text: 'Internalize your feelings, avoiding conflict.',
          nextScenarioId: 5),
      Choice(
          text: 'Take a break and call your partner to vent.',
          nextScenarioId: 5),
    ],
    perspectiveSwitch: 'Switch Perspective',
    perspectiveText:
        'How your partner perceives your behavior later in the day.',
    image: 'assets/images/scenario5.png',
  ),
  Scenario(
    text:
        'During lunch, both of you reflect on the morning. How do you reach out to each other?',
    choices: [
      Choice(text: 'Send a thoughtful message to check in.', nextScenarioId: 6),
      Choice(
          text:
              'Take a moment to look at a photo of you two together, smiling.',
          nextScenarioId: 6),
      Choice(
          text: 'Reflect on a happy memory to uplift your spirits.',
          nextScenarioId: 6),
    ],
    image: 'assets/images/scenario6.png',
  ),
  Scenario(
    text:
        'You receive a text from your partner about the conflict. How do you respond?',
    choices: [
      Choice(text: 'Offer supportive words and advice.', nextScenarioId: 7),
      Choice(
          text: 'Encourage them to take deep breaths and stay calm.',
          nextScenarioId: 7),
      Choice(
          text: 'Suggest they talk to a trusted friend or mentor.',
          nextScenarioId: 7),
    ],
    perspectiveSwitch: 'Switch Perspective',
    perspectiveText:
        'You are still affected by the conflict and the stress from the presentation. What do you do to cope?',
    image: 'assets/images/scenario7.png',
  ),
  Scenario(
    text:
        'Your partner calls you again, sounding more stressed. How do you handle the situation?',
    choices: [
      Choice(text: 'Listen patiently and offer empathy.', nextScenarioId: 8),
      Choice(
          text: 'Suggest practical steps to resolve the conflict.',
          nextScenarioId: 8),
      Choice(
          text:
              'Remind them of your plans for the evening to lift their spirits.',
          nextScenarioId: 8),
    ],
    image: 'assets/images/scenario8.png',
  ),
  Scenario(
    text:
        'You come home feeling exhausted. Suddenly you realize that you forgot to congratulate your partner for their anniversary. How do you react?',
    choices: [
      Choice(
          text: 'Apologize and explain how stressful your day has been.',
          nextScenarioId: 9),
      Choice(
          text: 'Say nothing while feeling deeply ashamed.', nextScenarioId: 9),
      Choice(
          text: 'Congratulate them and tell them how much you love them.',
          nextScenarioId: 9),
    ],
    perspectiveSwitch: 'Switch Perspective',
    perspectiveText:
        'You are excited to see your partner but sense their stress. At the same time, you are still disappointed that they forgot your anniversary. How do you react?',
    image: 'assets/images/scenario9.png',
  ),
  Scenario(
    text: 'You decide on dinner plans. What do you do?',
    choices: [
      Choice(
          text: 'Cook a meal together and talk about the day.',
          nextScenarioId: 10),
      Choice(text: 'Order takeout and relax with a movie.', nextScenarioId: 10),
      Choice(
          text: 'Go out to a favorite restaurant to change the atmosphere.',
          nextScenarioId: 10),
    ],
    image: 'assets/images/scenario10.png',
  ),
  Scenario(
    text: 'After dinner, how do you propose to spend the evening?',
    choices: [
      Choice(
          text: 'Watch a movie or show that you both enjoy.',
          nextScenarioId: 11),
      Choice(
          text: 'Take a walk together and talk about anything and everything.',
          nextScenarioId: 11),
      Choice(
          text: 'Play a game or engage in a shared hobby.', nextScenarioId: 11),
    ],
    perspectiveSwitch: 'Switch Perspective',
    perspectiveText:
        'After dinner, you suggest an activity. What do you choose?',
    image: 'assets/images/scenario10.png',
  ),
  Scenario(
    text:
        'As you prepare for bed, you reflect on the day. What are your final thoughts?',
    choices: [
      Choice(
          text: 'Gratitude for the moments shared and the support given.',
          nextScenarioId: 12),
      Choice(
          text: 'Thinking about how to be a better partner tomorrow.',
          nextScenarioId: 12),
      Choice(
          text: 'Feeling a deep sense of love and connection.',
          nextScenarioId: 12),
    ],
    perspectiveSwitch: 'Switch Perspective',
    perspectiveText: 'Reflecting on the day and your thoughts before bed.',
    image: 'assets/images/scenario10.png',
  ),
];
