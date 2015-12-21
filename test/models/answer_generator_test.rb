require 'test_helper'

class AnswerGeneratorTest < ActiveSupport::TestCase
  test "level1" do
    generator = AnswerGenerator.new
    question = questions :level1
    answer = answers :level1

    assert_equal answer.body, generator.level1(question.body)
  end

  test "level2" do
    generator = AnswerGenerator.new
    question_begin = questions :level2_begin
    question_middle = questions :level2_middle
    question_end = questions :level2_end
    
    answer_begin = answers :level2_begin
    answer_middle = answers :level2_middle
    answer_end = answers :level2_end
    
    assert_equal answer_begin.body, generator.level2(question_begin.body)
    assert_equal answer_middle.body, generator.level2(question_middle.body)
    assert_equal answer_end.body, generator.level2(question_end.body)
  end

  test "level3" do
    generator = AnswerGenerator.new
    question = questions :level3
    answer = answers :level3
    p answer, question
    assert_equal answer.body, generator.level3(question.body)
  end

  test "level4" do
    generator = AnswerGenerator.new
    question = questions :level4
    answer = answers :level4
    p answer, question
    assert_equal answer.body, generator.level4(question.body)
  end
end