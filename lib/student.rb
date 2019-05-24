require_relative "../config/environment.rb"
require "pry"

class Student

  attr_accessor :name,:grade,:id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name,grade,id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
      SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade) VALUES (?, ?)
      SQL
    DB[:conn].execute(sql,self.name,self.grade)
    id_q="SELECT id FROM students ORDER BY id DESC LIMIT 1"
    @id = DB[:conn].execute(id_q)[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ? , grade = ? WHERE id = ?
      SQL
    DB[:conn].execute(sql,self.name, self.grade, self.id)
  end

  def self.create(name,grade)
    student = Student.new(name,grade)
    student.save
    return student
  end

  def self.new_from_db(row)
    # [id,name,grade]
    return Student.new(row[1],row[2],row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
      SQL
    row = DB[:conn].execute(sql,name)
    row.collect do |row| self.new_from_db(row) end.first
  end

end
