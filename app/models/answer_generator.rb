class AnswerGenerator < ActiveRecord::Base


  def level1(question)
    poem = find_poem_by_full_string(question)
    title = poem.try(:title)
    #Poem.pluck(:body, :title).find { |p| p[0] =~ /#{question}/ }[1]
  end

  def level2(*questions)
    answer = []
    questions.each do |question|
      splited = question.partition '%WORD%'
      
      text = find_poem_with_replaced_word(splited).try :body
      answer << find_replaced_word_in_poem(text, splited)
    end
    answer.join ','
  end

  def level3(question)
    level2 *question.split("\n")
  end

  def level4(question)
    level2 *question.split("\n")
  end

  def level5(question)
    q = question.split
    q.each do |current_word|
      new_question = q.join(' ').sub /\s#{current_word}\s/, ' %WORD% '
      answer = level2(new_question)
      return "#{answer},#{current_word}" unless answer.blank?
    end
    nil
  end

  def level6(question)
    q = []
    @dictionary ||= words
    question.split.each do |anagram|
      q << @dictionary[anagram.chars.sort.join]
    end
    puts q.join ' '
    
    poem = find_poem_by_string_without_punctuation q.join ' '
    find_string_with_punctuation_in_poem_by_string_without_punctuation poem, q.join(' ')
  end

  #private

  def find_poem_by_full_string(string)
    find_poem_with_replaced_word string.partition ''
  end

  def find_poem_with_replaced_word(splited)
    Poem.where('body ~* ?', splited[0] + '[А-Яа-я]*' + splited[2]).first
  end

  def find_poem_by_string_without_punctuation(string)
    Poem.all.each do |poem|
      return poem if poem.body.gsub(/,|\.|\?|!|:|;||\)/, '') =~ /#{string}/
    end
    nil
  end

  def find_string_with_punctuation_in_poem_by_string_without_punctuation(poem, string)
    poem.try(:body).each_line do |line|
      return line.sub "\n", '' if line =~ Regexp.new(regexp_with_punctuation_from string)
    end unless poem.nil?
  end

  def find_replaced_word_in_poem(text, splited)
    if splited[0].empty?
      replaced_word = text.split(splited[2])[0].split(/\s|"|\(/)[-1] if text
    elsif splited[2].empty?
      replaced_word = text.split(splited[0])[1].split(/\s|,|\.|\?|!|:|;|\(|\)|"/)[0] if text
    else
      replaced_word = text.split(splited[0])[1].split(splited[2])[0] if text
    end
  end

  def words
    words = []
    Poem.all.pluck(:body).each do |poem|
      poem.split(/\s+/).each do |word|
        words << word.gsub(/,|\.|\?|!|:|;||\)/, '')
      end
    end
    
    words.uniq!
    words_hash = Hash.new
    words.each do |line|
      word = line.chomp
      words_hash[word.split('').sort!.join('')] = word

    end
    words_hash
  end

  def regexp_with_punctuation_from(string)
    result = ''
    string.split.each do |word|
    result += word + '([,|\.|\?|!|:|;|\)])*\s*'
      end
    result
  end

end
