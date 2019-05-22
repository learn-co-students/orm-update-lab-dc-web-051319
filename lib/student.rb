require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_reader :id
  attr_accessor :name, :grade

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id =id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
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
      
      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL 
      UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(student_row)
    id = student_row[0]
    name = student_row[1]
    grade = student_row[2]
    student = Student.new(name, grade, id)
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM students
      SQL

    DB[:conn].execute(sql).map{ |student_row| Student.new_from_db(student_row) }
  end

  def self.find_by_name(name)
    Student.all.find{ |student| student.name == name }
  end

end
