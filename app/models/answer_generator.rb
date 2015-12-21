class AnswerGenerator < ActiveRecord::Base
  def level1(question)
    poem = find_poem_by_full_string(question)
    title = poem.try(:title)
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

  def find_poem_by_full_string(question)
    find_poem_with_replaced_word question.partition ''
  end

  def find_poem_with_replaced_word(splited)
    Poem.where('body ~* ?', splited[0] + '[А-Яа-я]*' + splited[2]).first
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
end