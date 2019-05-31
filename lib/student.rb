require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
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
  DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save
    #if I already exist just update me
    if self.id
      self.update
    else
      #new instance of user to insert new student(name,grade) into database
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?,?)
      SQL
      #execute with this instance name, grade
       DB[:conn].execute(sql, self.name, self.grade)
       #this new instance doesn't have an id so we set its primrary key id equal to where we input this new instance in our database.
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    #create a new instance of students(name,grade)
    #save that new instance into the database
    #return what you created
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    #This class method takes an argument of an array. When we call this method we will pass it the array that is the row returned from the database by the execution of a SQL query.
    #The .new_from_db method uses these three array elements to create a new Student object with these attributes.
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(id, name, grade)



  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students WHERE name = ?
    SQL
        DB[:conn].execute(sql, name).map { |row| new_from_db(row) }.first

  end

  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

        DB[:conn].execute(sql, self.name, self.grade, self.id)

  end


end
