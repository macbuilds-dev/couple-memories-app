import 'package:flutter/material.dart';

/// Preset options for profile onboarding selection screens.
class ProfileOptions {
  static const genderPresets = [
    'Woman',
    'Man',
    'Non-binary',
    'Prefer not to say',
  ];

  static const hobbies = [
    'Photography', 'Cooking', 'Baking', 'Reading', 'Writing', 'Poetry',
    'Painting', 'Drawing', 'Sketching', 'Calligraphy', 'Music', 'Singing',
    'Guitar', 'Piano', 'Dancing', 'Yoga', 'Meditation', 'Running', 'Jogging',
    'Gym', 'Cycling', 'Swimming', 'Hiking', 'Trekking', 'Camping', 'Traveling',
    'Road trips', 'Backpacking', 'Gardening', 'Plants', 'Knitting', 'Crochet',
    'Sewing', 'Fashion', 'Shopping', 'Movies', 'Netflix', 'Anime', 'K-drama',
    'Gaming', 'Video games', 'Board games', 'Chess', 'Puzzles', 'Podcasts',
    'Blogging', 'Vlogging', 'Social media', 'Volunteering', 'Charity',
    'Football', 'Cricket', 'Basketball', 'Tennis', 'Badminton', 'Table tennis',
    'Volleyball', 'Martial arts', 'Boxing', 'Skating', 'Skiing', 'Surfing',
    'Fishing', 'Bird watching', 'Astronomy', 'Stargazing', 'Collecting',
    'Antiques', 'DIY crafts', 'Woodworking', 'Pottery', 'Sculpture',
    'Theater', 'Acting', 'Stand-up comedy', 'Karaoke', 'Concerts', 'Festivals',
    'Coffee tasting', 'Tea culture', 'Wine tasting', 'Food exploring',
    'Street food', 'Fine dining', 'Home decor', 'Interior design',
    'Architecture', 'History', 'Museums', 'Art galleries', 'Nature walks',
    'Beach days', 'Mountain climbing', 'Horse riding', 'Pet care',
    'Dog training', 'Cat lover', 'Aquarium', 'Photography walks',
    'Language learning', 'Book clubs', 'Journaling', 'Scrapbooking',
    'Origami', 'Magic tricks', 'Astrology', 'Tarot', 'Fitness challenges',
  ];

  static const languages = [
    'English', 'Urdu', 'Hindi', 'Punjabi', 'Sindhi', 'Pashto', 'Balochi',
    'Arabic', 'Persian', 'Turkish', 'Bengali', 'Tamil', 'Telugu', 'Marathi',
    'Gujarati', 'Kannada', 'Malayalam', 'French', 'Spanish', 'German',
    'Italian', 'Portuguese', 'Dutch', 'Russian', 'Ukrainian', 'Polish',
    'Czech', 'Romanian', 'Greek', 'Swedish', 'Norwegian', 'Danish', 'Finnish',
    'Chinese (Mandarin)', 'Cantonese', 'Japanese', 'Korean', 'Vietnamese',
    'Thai', 'Indonesian', 'Malay', 'Filipino', 'Burmese', 'Khmer', 'Lao',
    'Hebrew', 'Swahili', 'Amharic', 'Hausa', 'Yoruba', 'Zulu', 'Afrikaans',
    'Hungarian', 'Serbian', 'Croatian', 'Bulgarian', 'Slovak', 'Lithuanian',
    'Latvian', 'Estonian', 'Icelandic', 'Irish', 'Welsh', 'Scottish Gaelic',
    'Catalan', 'Basque', 'Galician', 'Sign language', 'Braille',
  ];

  static const dreamTravel = [
    'Paris, France', 'London, UK', 'Rome, Italy', 'Barcelona, Spain',
    'Amsterdam, Netherlands', 'Vienna, Austria', 'Prague, Czech Republic',
    'Budapest, Hungary', 'Athens, Greece', 'Santorini, Greece',
    'Istanbul, Turkey', 'Cappadocia, Turkey', 'Dubai, UAE', 'Abu Dhabi, UAE',
    'Doha, Qatar', 'Riyadh, Saudi Arabia', 'Makkah, Saudi Arabia',
    'Madinah, Saudi Arabia', 'Muscat, Oman', 'Cairo, Egypt',
    'Marrakech, Morocco', 'Cape Town, South Africa', 'Nairobi, Kenya',
    'Zanzibar, Tanzania', 'Maldives', 'Bali, Indonesia', 'Bangkok, Thailand',
    'Phuket, Thailand', 'Singapore', 'Kuala Lumpur, Malaysia',
    'Tokyo, Japan', 'Kyoto, Japan', 'Osaka, Japan', 'Seoul, South Korea',
    'Beijing, China', 'Shanghai, China', 'Hong Kong', 'Taipei, Taiwan',
    'Sydney, Australia', 'Melbourne, Australia', 'Queenstown, New Zealand',
    'New York, USA', 'Los Angeles, USA', 'San Francisco, USA',
    'Las Vegas, USA', 'Miami, USA', 'Chicago, USA', 'Washington DC, USA',
    'Toronto, Canada', 'Vancouver, Canada', 'Mexico City, Mexico',
    'Cancún, Mexico', 'Rio de Janeiro, Brazil', 'Buenos Aires, Argentina',
    'Lima, Peru', 'Machu Picchu, Peru', 'Patagonia, Argentina/Chile',
    'Reykjavik, Iceland', 'Lapland, Finland', 'Norway Fjords', 'Swiss Alps',
    'Interlaken, Switzerland', 'Zurich, Switzerland', 'Edinburgh, Scotland',
    'Dublin, Ireland', 'Lisbon, Portugal', 'Porto, Portugal',
    'Kraków, Poland', 'Stockholm, Sweden', 'Copenhagen, Denmark',
    'Helsinki, Finland', 'Moscow, Russia', 'St. Petersburg, Russia',
    'Tbilisi, Georgia', 'Baku, Azerbaijan', 'Samarkand, Uzbekistan',
    'Kathmandu, Nepal', 'Bhutan', 'Sri Lanka', 'Goa, India', 'Kerala, India',
    'Rajasthan, India', 'Agra, India', 'Lahore, Pakistan', 'Karachi, Pakistan',
    'Islamabad, Pakistan', 'Hunza, Pakistan', 'Skardu, Pakistan',
    'Murree, Pakistan', 'Swat, Pakistan', 'Istanbul & Cappadocia, Turkey',
    'Petra, Jordan', 'Jerusalem', 'Bora Bora, French Polynesia',
    'Hawaii, USA', 'Alaska, USA', 'Grand Canyon, USA', 'Yellowstone, USA',
  ];

  static const skills = [
    'Programming', 'Web development', 'Mobile development', 'UI/UX design',
    'Graphic design', 'Video editing', 'Photography', 'Content writing',
    'Copywriting', 'SEO', 'Digital marketing', 'Social media marketing',
    'Data analysis', 'Excel', 'PowerPoint', 'Public speaking',
    'Leadership', 'Project management', 'Time management', 'Negotiation',
    'Sales', 'Customer service', 'Teaching', 'Tutoring', 'Mentoring',
    'Cooking', 'Baking', 'Gardening', 'First aid', 'CPR', 'Driving',
    'Car maintenance', 'Bike repair', 'Sewing', 'Knitting', 'Carpentry',
    'Plumbing basics', 'Electrical basics', 'Home repair', 'Interior styling',
    'Event planning', 'Wedding planning', 'Accounting', 'Bookkeeping',
    'Financial planning', 'Investing basics', 'Languages', 'Translation',
    'Interpretation', 'Music production', 'Singing', 'Playing instruments',
    'Drawing', 'Painting', 'Pottery', 'Calligraphy', 'Acting', 'Dancing',
    'Fitness training', 'Yoga instruction', 'Swimming coaching',
    'Sports coaching', 'Chess', 'Debate', 'Research', 'Academic writing',
    'Legal knowledge', 'Medical knowledge', 'Nursing care', 'Childcare',
    'Elder care', 'Pet training', 'Veterinary basics', 'Photoshop',
    'Illustrator', 'Figma', 'Canva', '3D modeling', 'Animation',
    'Machine learning', 'AI tools', 'Cybersecurity basics', 'Networking',
    'Cloud computing', 'DevOps', 'Database management', 'Linux',
    'Microsoft Office', 'Google Workspace', 'Notion', 'Productivity systems',
    'Negotiation in business', 'Resume writing', 'Interview coaching',
    'Photography editing', 'Drone flying', 'Swimming', 'Martial arts',
  ];

  static const wantsToLearn = [
    'Programming', 'App development', 'AI & machine learning', 'Data science',
    'Cybersecurity', 'Cloud computing', 'Digital marketing', 'SEO',
    'Graphic design', 'UI/UX design', 'Video editing', 'Photography',
    'Music production', 'Playing guitar', 'Playing piano', 'Singing',
    'Dancing', 'Painting', 'Drawing', 'Calligraphy', 'Pottery',
    'Cooking', 'Baking', 'Nutrition', 'Fitness', 'Yoga', 'Meditation',
    'Mindfulness', 'Public speaking', 'Leadership', 'Entrepreneurship',
    'Investing', 'Personal finance', 'Stock market', 'Real estate',
    'Languages', 'Spanish', 'French', 'Arabic', 'Chinese', 'Japanese',
    'Korean', 'German', 'Italian', 'Sign language', 'Writing', 'Poetry',
    'Creative writing', 'Blogging', 'Storytelling', 'History', 'Philosophy',
    'Psychology', 'Sociology', 'Astronomy', 'Physics', 'Chemistry',
    'Biology', 'Mathematics', 'Economics', 'Law basics', 'Medical basics',
    'First aid', 'Gardening', 'Plant care', 'Interior design', 'Fashion',
    'Sewing', 'Knitting', 'Woodworking', 'DIY home projects', 'Car mechanics',
    'Motorcycle riding', 'Swimming', 'Scuba diving', 'Surfing', 'Rock climbing',
    'Chess', 'Poker', 'Negotiation', 'Conflict resolution', 'Parenting',
    'Child development', 'Pet training', 'Wine appreciation', 'Coffee brewing',
    'Tea ceremony', 'Travel planning', 'Photography composition',
    'Social media growth', 'Content creation', 'Podcasting', 'Acting',
    'Stand-up comedy', 'Magic tricks', 'Astrology', 'Tarot reading',
    'Sustainable living', 'Minimalism', 'Time management', 'Productivity',
    'Memory techniques', 'Speed reading', 'Emotional intelligence',
  ];

  static IconData iconFor(String label) {
    final key = label.toLowerCase();
    if (key.contains('photo') || key.contains('camera')) return Icons.camera_alt_outlined;
    if (key.contains('cook') || key.contains('food') || key.contains('baking')) {
      return Icons.restaurant_outlined;
    }
    if (key.contains('music') || key.contains('sing') || key.contains('guitar')) {
      return Icons.music_note_outlined;
    }
    if (key.contains('travel') || key.contains('trip')) return Icons.flight_outlined;
    if (key.contains('game') || key.contains('gaming')) return Icons.sports_esports_outlined;
    if (key.contains('read') || key.contains('book')) return Icons.menu_book_outlined;
    if (key.contains('run') || key.contains('gym') || key.contains('fitness')) {
      return Icons.fitness_center_outlined;
    }
    if (key.contains('swim')) return Icons.pool_outlined;
    if (key.contains('art') || key.contains('paint') || key.contains('draw')) {
      return Icons.palette_outlined;
    }
    if (key.contains('language') || key.contains('urdu') || key.contains('english')) {
      return Icons.translate_outlined;
    }
    if (key.contains('shop')) return Icons.shopping_bag_outlined;
    if (key.contains('movie') || key.contains('netflix')) return Icons.movie_outlined;
    if (key.contains('code') || key.contains('program')) return Icons.code_outlined;
    if (key.contains('design')) return Icons.design_services_outlined;
    if (key.contains('yoga') || key.contains('meditat')) return Icons.self_improvement_outlined;
    if (key.contains('garden')) return Icons.local_florist_outlined;
    if (key.contains('dance')) return Icons.nightlife_outlined;
    return Icons.favorite_border;
  }
}
