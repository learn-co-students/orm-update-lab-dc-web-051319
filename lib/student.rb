require_relative "../config/environment.rb"

class Student

    # Remember, you can access your database connection anywhere in this class
    #  with DB[:conn]

    attr_accessor :id, :name, :grade
    
    def initialize(id=nil, name, grade)
        @id, @name, @grade = id, name, grade
    end
    
    def self.new_from_db(row)
        self.new(row[0], row[1], row[2])
    end

    def self.create(name, grade)
        self.new(name, grade).save 
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
        sql = "DROP TABLE IF EXISTS students"
        DB[:conn].execute(sql)
    end

    def self.all
        DB[:conn].execute("SELECT * FROM students").map do |student|
            self.new_from_db(student)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
                FROM students
            WHERE name = ?
            LIMIT 1
        SQL
        
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO students (name, grade)
            VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.grade)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
        end
    end

    def update
        sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

end
