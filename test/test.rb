require 'test/unit'
require '../lib/core'

class MyTest < Test::Unit::TestCase
  def setup
    foo = StringIO.new
    $stderr = foo
    $stdout = foo
    @parser = Parser.new
  end

  #def teardown
  #end

  def test_no_arguments
    @parser.execute []
    assert_equal("Usage is './parser.rb [path_to_file]'.\n", $stderr.string)
  end

  def test_multiple_arguments
    @parser.execute %w(inexisting.log webserver.log some_param)
    assert_equal("Usage is './parser.rb [path_to_file]'.\n", $stderr.string)
  end

  def test_non_existing_file
    @parser.execute ['inexisting.log']
    assert_equal("No such file or directory @ rb_sysopen - inexisting.log\n", $stderr.string)
  end

  def test_read_error
    File.chmod(0000, "non_readable.log")
    @parser.execute ['non_readable.log']
    assert_equal("Permission denied @ rb_sysopen - non_readable.log\n", $stderr.string)
  end

  def test_invalid_integer
    assert_raise_message "invalid value for Integer(): \"x126318035038\"" do
      VisitsEntry.new "/help_page/1 x126.318.035.038", 1
    end
  end

  def test_decimal_row_10
    assert_raise_message "invalid value for Integer(): \"126318,035038\"" do
      VisitsEntry.new "/help_page/1 126.318,035.038", 10
    end
  end

  def test_too_many_values_row_2
    assert_raise_message "Incorrect number of values at line 2" do
      VisitsEntry.new "/help_page/1 126.318.035 038", 2
    end
  end

  def test_negative_values_row_2
    assert_raise_message "Negative value -126318035038 at line 2" do
      VisitsEntry.new "/help_page/1 -126.318.035.038", 2
    end
  end

  def test_negative_zero_row_2
    VisitsEntry.new "/help_page/1 -0", 2
    VisitsEntry.new "/help_page/1 0", 2
  end

  def test_tab_separator_spaces
    VisitsEntry.new "/help_page/1\t126.318.035.038", 2
  end

  def test_multiple_separator_spaces
    VisitsEntry.new "/help_page/1    126.318.035.038", 2
  end

  def test_leading_trailing_spaces
    VisitsEntry.new " /help_page/1 126.318.035.038 ", 2
    VisitsEntry.new "\t/help_page/1 126.318.035.038\v\r", 2
    VisitsEntry.new "   /help_page/1 126.318.035.038\t\t", 2
  end

  def test_integer_parse
    VisitsEntry.new " /help_page/1 026.318.035.038 ", 2
    VisitsEntry.new " /help_page/1 000026.318.035.038 ", 2
    VisitsEntry.new " /help_page/1 26.318.035.038 ", 2
    VisitsEntry.new " /help_page/1 6.318.035.038 ", 2
  end

  def test_simple_output
    # /about/2 , /about/3, /help_page/1 and /index are unique
    @parser.execute ['simple.log']
    assert_equal("/home 2846955522540 visits " +
                     "/contact 964021096640 visits "+
                     "/about 830989210475 visits " +
                     "/help_page/1 577424239959 visits "+
                     "/help_page/2 351106204921 unique views \n"+
                     "/index 200017277774 unique views \n"+
                     "/about/3 84123665067 unique views \n"+
                     "/about/2 16464657359 unique views \n",
                 $stdout.string)
  end


  def test_unique_larger_than_others
    # test sorting when unique views exceed number of regular visits
    # /about/2 , /about/3, /help_page/1 and /index are unique
    @parser.execute ['simple_many_unique.log']
    assert_equal("/home 2846955522540 visits " +
                     "/contact 964021096640 visits "+
                     "/about 830989210475 visits " +
                     "/help_page/1 577424239959 visits "+
                     "/about/2 9916464657359 unique views \n"+
                     "/about/3 984123665067 unique views \n"+
                     "/help_page/2 351106204921 unique views \n"+
                     "/index 200017277774 unique views \n",
                 $stdout.string)
  end

  def test_webserver_log
    @parser.execute ['webserver.log']
    assert_equal("/about 38235806392955 visits "+
                     "/contact 38048910465585 visits "+
                     "/index 37572050801356 visits "+
                     "/help_page/1 37294021322532 visits "+
                     "/about/2 35297282658615 visits "+
                     "/home 34287265872916 visits ",
                 $stdout.string)
  end


end
