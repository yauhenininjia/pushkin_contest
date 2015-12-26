class AnswerGenerator < ActiveRecord::Base


  def level1(question)
    #poem = find_poem_by_full_string(question)
    #title = poem.try(:title)

    Poem.basic_search(question).first.title

    #Poem.search(question).first.title

    #Poem.pluck(:body, :title).find { |p| p[0] =~ /#{question}/ }[1]
  end

  def level2(*questions)
    answer = []
    questions.each do |question|
      splited = question.partition '%WORD%'
      
      @poem ||= find_poem_with_replaced_word(splited)
      
      text = @poem.try :body
      
      answer << find_replaced_word_in_poem(text, splited)
      
      @poem = nil if answer.compact.empty?
    end
    logger.info "ANSWER!!! #{answer}"
    answer.join ','
  end

  def level3(question)
    level2 *question.split("\n")
  end

  def level4(question)
    level2 *question.split("\n")
  end

  def level5(question)
    q = question.gsub(/,|\.|\?|!|:|;|\)/, '').split
    q.each do |current_word|
      q[q.index current_word] = '%WORD%'
      new_question = q.join ' '#q.join(' ').sub /\s#{current_word}\s/, ' %WORD% '
      
      q[q.index '%WORD%'] = current_word
      answer = level2(new_question)
      
      return "#{answer},#{current_word}" unless answer.blank?
    end
    nil
  end

  def level6(question)
    q = []
    @@dictionary ||= words
    question.split.each do |anagram|
      q << @@dictionary[anagram.chars.sort.join]
    end
    #puts q.join ' '
    
    poem = find_poem_by_string_without_punctuation q.join ' '
    find_string_with_punctuation_in_poem_by_string_without_punctuation poem, q.join(' ')
  end

  def level7(question)
    q = []
    @@dictionary ||= lines
    
    q << @@dictionary[question.chars.sort.join.strip]
    
    #puts q.join ' '

    poem = find_poem_by_string_without_punctuation q.join ' '
    find_string_with_punctuation_in_poem_by_string_without_punctuation poem, q.join(' ')
  end

  def level8(question)
    q = []
    @@dictionary ||= lines
    
    question.length.times do |i|
      ['А'..'Я', 'а'..'я'].each do |range|
        range.each do |char|
          duplicate = question.dup
          duplicate[i] = char

          q << @@dictionary[duplicate.chars.sort.join.strip]
          #binding.pry
          
          break unless q.compact.empty?
        end
        break unless q.compact.empty?
      end
    end
    q.uniq!.compact!
    #puts q.join ' '

    #binding.pry
    poem = find_poem_by_string_without_punctuation q.join ' '
    find_string_with_punctuation_in_poem_by_string_without_punctuation poem, q.join(' ')
  end

  #7 "ротаик вбонесвройС й йытто"
  #Parameters: {"question"=>"втн н еястлеН яи овчаа", "id"=>794977, "level"=>8}
  # "лр ыо нлвечдГНаеуиа уциоя "

  #private

  def find_poem_by_full_string(string)
    find_poem_with_replaced_word string.partition ''
  end

  def find_poem_with_replaced_word(splited)
    #Poem.where('body ~* ?', splited[0] + '[А-Яа-я]*' + splited[2]).first
    #Poem.search("#{splited[0]} * #{splited[2]}").first
    Poem.basic_search("#{splited[0]} * #{splited[2]}").each do |poem|
      return poem if poem.body =~ /#{splited[0].gsub(/\A\p{Space}*/, '').strip}.*#{splited[2]}/
    end
    nil
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
=begin
    if splited[0].empty?
      replaced_word = text.split(splited[2])[0].split(/\s|"|\(/)[-1] if text && text.length > text.split(splited[2])[0].length
    elsif splited[2].empty?
      replaced_word = text.split(splited[0])[1].split(/\s|,|\.|\?|!|:|;|\(|\)|"/)[0] if text && text.length > text.split(splited[0])[1].length
    else
      replaced_word = text.split(splited[0])[1].split(splited[2])[0] if text && text.split(splited[0])[1] && text.length > text.split(splited[0])[1].length
    end
    
    replaced_word
=end
    
    # up to 9 times slowly
    text.split("\n").find{ |s| s =~ /#{splited[0].gsub(/\A\p{Space}*/, '').strip}.*#{splited[2]}/  }
      .sub(splited[0].gsub(/\A\p{Space}*/, ''), '').sub(splited[2], '').strip if text
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

  def lines
    lines = []
    Poem.all.pluck(:body).each do |poem|
      poem.split("\n").each do |line|
        lines << line.gsub(/,|\.|\?|!|:|;|\)|—/, '')
      end
    end

    lines.uniq!
    lines_hash = Hash.new
    lines.each do |line|
      word = line.chomp
      lines_hash[word.split('').sort!.join('').strip] = word

    end
    lines_hash
  end

  def regexp_with_punctuation_from(string)
    result = ''
    string.split.each do |word|
    result += word + '([,|\.|\?|!|:|;|\)])*\s*'
      end
    result
  end

end
