import '../models/scenario.dart';

final List<Scenario> story = [
  Scenario(
    text:
        'Welcome to "A Day in the Life." Today, you will step into the shoes of one partner in a fictional story involving a couple. Throughout the day, you will make choices based on what you think works best for each situation. These decisions will shape the course of the story, leading to different outcomes. After completing the game, you will receive a summary showing how your choices are perceived from the other partner’s perspective. Let\'s begin.',
    choices: [
      Choice(text: 'Start Game', nextScenarioId: 1),
    ],
    image: null, // No image for this scenario
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
    ],
    otherPerspectives: [
      'You wake up and realize your partner has already left. It\'s your anniversary, and you feel a bit disappointed they didn\'t wake you up to celebrate. You took the day off to spend it together. Hoping for a loving reply, you decide to send them a good morning text.',
      'You wake up and feel disappointed that your partner didn’t wake you. You took the day off to celebrate, and now you feel neglected as you wait for them to acknowledge the anniversary.'
    ],
    image: 'assets/images/scenario1.png',
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
              'Send a loving reply, "Good morning, love you, busy with the presentation."',
          nextScenarioId: 3),
    ],
    otherPerspectives: [
      'You read your partner\'s reply and feel a mix of emotions. They didn\'t mention the anniversary, which makes you feel neglected and unimportant.',
      'You read the distracted reply and feel like work is more important to them than the anniversary. You start to feel disconnected.',
      'You smile at the reply, but a small part of you still feels disappointed that they didn\'t acknowledge the anniversary.'
    ],
    image: 'assets/images/scenario2.png',
  ),
  Scenario(
    text:
        'The presentation at work is intense, and you face unexpected challenges. You\'re stressed and anxious. How do you handle the situation?',
    choices: [
      Choice(
          text: 'Push through the stress, determined to succeed.',
          nextScenarioId: 4),
      Choice(
          text: 'Think of calling your partner for support during a break.',
          nextScenarioId: 4),
    ],
    otherPerspectives: [
      'You try to be understanding, knowing your partner has a big day too, but you feel a bit disappointed as you hope they will reach out.',
      'You feel worried for your partner, but you can\'t help but feel a little disappointed about the morning.'
    ],
    image: 'assets/images/scenario3.png',
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
    ],
    otherPerspectives: [
      'You worry about how stressed your partner is. You wish they would reach out to you.',
      'You know your partner is dealing with a lot, but their silence makes you feel distant.'
    ],
    image: 'assets/images/scenario4.png',
  ),
  Scenario(
    text:
        'Your lunch break is short because of the discussion with your colleague. You miss your partner. How do you reach out?',
    choices: [
      Choice(text: 'Send a thoughtful message to check in.', nextScenarioId: 6),
      Choice(
          text: 'Take a moment to look at a photo of you two smiling.',
          nextScenarioId: 6),
      Choice(
          text: 'Reflect on a happy memory to lift your spirits.',
          nextScenarioId: 6),
    ],
    otherPerspectives: [
      'If you receive a thoughtful message from your partner, it lifts your spirits. You feel closer to them despite the busy day.',
      'If you don’t hear from your partner, you feel increasingly distant, wondering if they care about the anniversary at all.'
    ],
    image: 'assets/images/scenario5.png',
  ),
  Scenario(
    text:
        'You are exhausted after work and receive a text from your partner about a conflict they had with a friend. How do you respond?',
    choices: [
      Choice(text: 'Offer supportive words and advice.', nextScenarioId: 7),
      Choice(
          text: 'Encourage them to take deep breaths and stay calm.',
          nextScenarioId: 7),
      Choice(text: 'Suggest they talk to a trusted friend.', nextScenarioId: 7),
    ],
    otherPerspectives: [
      'Depending on your response, your partner either feels supported or even more frustrated. You sense a shift in their mood.',
      'Your partner’s tone changes. They sound either appreciative or frustrated, depending on how you respond.'
    ],
    image: 'assets/images/scenario6.png',
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
    otherPerspectives: [
      'Your partner feels heard and supported, which lightens their mood.',
      'Your practical steps help, but your partner might still feel the weight of the day.',
      'Your reminder of evening plans brings a smile to their face, but there’s still an underlying tension.'
    ],
    image: 'assets/images/scenario7.png',
  ),
  Scenario(
    text:
        'You come home feeling exhausted. You realize you forgot to congratulate your partner on the anniversary. How do you react?',
    choices: [
      Choice(
          text: 'Apologize and explain how stressful your day has been.',
          nextScenarioId: 9),
      Choice(
          text: 'Say nothing while feeling deeply ashamed.', nextScenarioId: 9),
      Choice(
          text: 'Congratulate them and express your love.', nextScenarioId: 9),
    ],
    otherPerspectives: [
      'Your partner appreciates your apology but is still a bit hurt.',
      'Your silence leaves your partner feeling even more neglected, but they try to be understanding.',
      'Your words bring comfort, though the day’s tension still lingers.'
    ],
    image: 'assets/images/scenario8.png',
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
    otherPerspectives: [
      'Dinner helps ease the tension, and the conversation brings you closer.',
      'A relaxing evening lightens the mood, though there’s still some underlying tension.',
      'The change of atmosphere at the restaurant helps you both feel more connected.'
    ],
    image: 'assets/images/scenario9.png',
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
    otherPerspectives: [
      'The shared activity helps you unwind and remember the joy in your relationship.',
      'The walk brings up meaningful conversation, and you start to feel closer again.',
      'Playing a game together reminds you of the fun you always have.'
    ],
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
      image: null, // No image for this scenario
      singlePerspective:
          'You reflect on the day and appreciate the love you share despite the ups and downs.'),
];
