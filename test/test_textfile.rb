# encoding: utf-8
require 'helper'

class TestTextfile < Minitest::Test
  def infile(*records)
    file = Tempfile.new(self.class.name)
    file.puts(records)
    file.close
    file
  end

  should "clear a file" do
    file = infile('3','2','1')

    textfile = Textfile.new(file.path)
    textfile.clear

    file = File.open(textfile.path)
    assert_equal([], file.read.split)
  end

  should "find the intersection of two datasets" do
    set1 = infile('3','2','1','b')
    set2 = infile('c','b','a','2')

    tf1 = Textfile.new(set1.path)
    tf2 = Textfile.new(set2.path)
    tf1.sort.intersection(tf2.sort)

    file = File.open(tf1.path)
    assert_equal(['2','b'], file.read.split)
  end

  should "merge two datasets" do
    set1 = infile('3','2','1','b')
    set2 = infile('c','b','a','2')

    tf1 = Textfile.new(set1.path)
    tf2 = Textfile.new(set2.path)
    tf1.merge(tf2).sort

    file = File.open(tf1.path)
    assert_equal(['1','2','3','a','b','c'], file.read.split)
  end

  should "sort a simple file" do
    file = infile(['3','2','1'])

    textfile = Textfile.new(file.path)
    textfile.sort

    file = File.open(textfile.path)
    assert_equal(file.read.split, ['1', '2', '3'])
  end

  should "sort a file with very long records" do
    file = infile('3'*9999,'2','1')

    textfile = Textfile.new(file.path)
    textfile.sort

    file = File.open(textfile.path)
    assert_equal(file.read.split, ['1', '2', '3'*9999])
  end

  should "sort non-ASCII characters" do
    file = infile('Muffler','MX Systems','Müller','MySQL')

    textfile = Textfile.new(file.path)
    textfile.sort

    file = File.open(textfile.path, external_encoding: 'UTF-8')
    assert_equal(file.read.split("\n"), ["MX Systems", "Muffler", "MySQL", "Müller"])
  end
end
