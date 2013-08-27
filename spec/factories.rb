FactoryGirl.define do
  factory :user do
    name    'Sum Yung Guy'
  end

  factory :record do
    title        'An Unimportant Thing'
    description  'Not all things are important.  This one is a good example.'
    author       'George W. Bush'
    registered   true
    content      'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod'
  end

  factory :worth_saving_record do
    title        'So Important'
    description  'This thing must be saved at all costs.'
    author       'Elon Musk'
    registered   true
    content      'Cheaper, faster and safer than a so-called high-speed train'
  end

  factory :worth_saving_user_record do
    association  :user
    title        'So Important'
    description  'This thing must be saved at all costs and scoped to a user if it has not yet been persisted.'
    author       'Elon Musk'
    registered   true
    content      'Cheaper, faster and safer than a so-called high-speed train'
  end

end