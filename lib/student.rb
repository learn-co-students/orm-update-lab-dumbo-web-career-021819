require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_reader :id
  attr_accessor :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER);
      SQL

      DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save_first_time
    sql =<<-SQL
      INSERT INTO students
      (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, @name, @grade)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def update ######################?
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @grade, @id)
  end

  def save
    if @id == nil
      save_first_time
    else
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, @name, @grade, @id)
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row) #############?????????????????
    new_student = Student.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql=<<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL

    student_info = DB[:conn].execute(sql, name)[0]
    self.new_from_db(student_info)

  end

end
