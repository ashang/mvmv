require 'rubygems'
require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mvmv'

class TestMvmv < Test::Unit::TestCase
  def test_name_conversion
    m = Mvmv.new
    input = %w[aaa.jpg bbb.GIF ccc.jpg.png]
    assert_equal input.zip(%w[photo001.jpg photo002.GIF photo003.png]), m.convert_filenames(:name, 'photo###', *input)
    assert_equal input.zip(%w[old_aaa.jpg old_bbb.GIF old_ccc.jpg.png]), m.convert_filenames(:prefix, 'old_', *input)
    assert_equal input.zip(%w[001-aaa.jpg 002-bbb.GIF 003-ccc.jpg.png]), m.convert_filenames(:prefix, '###-', *input)
    assert_equal input.zip(%w[aaa.jpg.0001 bbb.GIF.0002 ccc.jpg.png.0003]), m.convert_filenames(:suffix, '.####', *input)
    assert_equal input.zip(%w[aaa-0001.jpg bbb-0002.GIF ccc.jpg-0003.png]), m.convert_filenames(:name_suffix, '-####', *input)
    assert_equal input.zip(%w[aaa.jpeg bbb.jpeg ccc.jpg.jpeg]), m.convert_filenames(:ext, '.jpeg', *input)
    assert_equal input.zip(%w[AAA.JPG BBB.GIF CCC.JPG.PNG]), m.convert_filenames(:upper, *input)
    assert_equal input.zip(%w[aaa.jpg bbb.gif ccc.jpg.png]), m.convert_filenames(:lower, *input)

    input = %w[abc.jpg xyz.GIF ijk.jpg.png]
    assert_equal input.zip(%w[cba01.jpg zyx02.GIF kji03.jpg.png]), m.convert_filenames(:regexp, '^([a-z])([a-z])([a-z])', '\3\2\1##', *input)
    assert_equal input.zip(input), m.convert_filenames(:regexp, '^([A-Z])([A-Z])([A-Z])', '\3\2\1##', *input)
    assert_equal input.zip(%w[cba01.jpg zyx02.GIF kji03.jpg.png]), m.convert_filenames(:regexpi, '^([A-Z])([a-z])([A-Z])', '\3\2\1##', *input)

    assert_equal input.zip(%w[cba01.gpj01 zyx02.GIF kji03.gpj03.gnp03]), m.convert_filenames(:regexp, '([a-z])([a-z])([a-z])', '\3\2\1##', *input)

    input = %w[Abc.jpg xyz.GIF ijk.jpg.png]
    assert_equal input.zip(%w[Abc.jpg zyx02.GIF kji03.gpj03.png]), m.convert_filenames(:name_regexp, '([a-z])([a-z])([a-z])', '\3\2\1##', *input)
    assert_equal input.zip(%w[cbA01.jpg zyx02.GIF kji03.gpj03.png]), m.convert_filenames(:name_regexpi, '([a-z])([a-z])([a-z])', '\3\2\1##', *input)
  end

  def test_name_conversion_directory
    m = Mvmv.new
    input = %w[aaa.jpg bbb.GIF ccc.jpg.png].map { |e| "x/y/z/#{e}" }
    assert_equal input.zip(
      %w[001-aaa.jpg 002-bbb.GIF 003-ccc.jpg.png].map { |e| "x/y/z/#{e}" }
    ), m.convert_filenames(:prefix, '###-', *input)
  end

  def test_rename!
    m = Mvmv.new

    input = %w[aaa.jpg bbb.gif ccc.jpg.png]
    pairs = m.convert_filenames :ext, '.jpeg', *input

    pairs.each do |pair|
      system "rm -v #{pair.join ' '}"
    end

    input.each do |file|
      system "touch #{file}"
    end
    system "touch #{pairs.last.last}"

    pairs.each do |pair|
      assert File.exist?(pair.first), 'File should exist'
      assert !File.exist?(pair.last), 'File should not exist' unless pair.last == pairs.last.last
    end

    m.rename! :ext, '.jpeg', *input

    pairs.each do |pair|
      assert !File.exist?(pair.first), 'File should not exist'
      assert File.exist?(pair.last), 'File should exist'
    end

    pairs.each do |pair|
      system "rm -v #{pair.join ' '}"
    end
  end

  def test_rename_dir
    m = Mvmv.new

    input = %w[aaa bbb ccc]
    pairs = m.convert_filenames :name, '##', *input
    pairs.each do |pair|
      system "rm -rfv #{pair.join ' '}"
      system "mkdir -pv #{pair.first}"
    end

    m.rename! :name, '##', *input

    pairs.each do |pair|
      assert !File.exist?(pair.first), 'Directory should not exist'
      assert File.exist?(pair.last), 'Directory should exist'
      assert File.directory?(pair.last), 'Should be a directory'
    end

    pairs.each do |pair|
      system "rm -rfv #{pair.join ' '}"
    end
  end
end
