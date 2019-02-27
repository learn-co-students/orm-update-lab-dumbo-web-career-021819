require_relative "../config/environment.rb"

class Student
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
    attr_accessor :id, :name, :grade

    def initialize(id = nil, name, grade)
      @id = id
      @name = name
      @grade = grade
    end

    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade INTEGER
        );
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = <<-SQL
        DROP TABLE IF EXISTS students;
      SQL
      DB[:conn].execute(sql)
    end

    def save
      if self.id != nil
        self.update
      else
        sql = <<-SQL
          INSERT INTO students (name, grade)
          VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.grade)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
    end

    def self.create(name, grade)
      student = Student.new(name, grade)
      student.save
      student
    end

    # row variable = the array that is returned from the database for a given
    # database row.
    def self.new_from_db(row)
      student = Student.new(row[0], row[1], row[2])
      student.id = row[0]
      student.name = row[1]
      student.grade = row[2]
      student
    end

    # returns an instance of student that matches the name from the DB
    def self.find_by_name(name)
      sql = <<-SQL
          SELECT *
          FROM students
          WHERE name = ?
        SQL
      result = DB[:conn].execute(sql, name)[0]
      Student.new(result[0], result[1], result[2])
    end

    def update
      sql = <<-SQL
          UPDATE students
          SET name = ?, grade = ?
          WHERE id = ?
        SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end

end
