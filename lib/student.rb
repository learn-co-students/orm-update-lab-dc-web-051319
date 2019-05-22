# frozen_string_literal: true

require_relative '../config/environment.rb'

class Student
  attr_reader :id
  attr_accessor :name, :grade

  def initialize(name, grade, id = nil)
    @name = name
    @id = id
    @grade = grade
  end

  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id integer PRIMARY KEY,
      name TEXT,
      grade integer
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    Student.new_from_db(DB[:conn].execute(sql, name).first)
  end

  def save
    if id
      update
    else
      sql = <<-SQL
      INSERT INTO students(name, grade)
      VALUES(?, ?)
      SQL

      DB[:conn].execute(sql, name, grade)
      @id = DB[:conn].execute('SELECT last_insert_rowid() FROM students')[0][0]
    end
  end

  def update
    sql = <<-SQL
    UPDATE students
    SET name = ?, grade = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, name, grade, id)
  end
end
