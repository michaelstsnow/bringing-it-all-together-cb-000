class Dog

  attr_accessor :id, :name, :breed

  def initialize( name:, breed:, id:nil)
    @name=name
    @breed=breed
    @id=id
  end

  def self.create_table
    sql=<<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql=<<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql=<<-SQL
      INSERT INTO dogs (name,breed)
      VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql=<<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id=?
    SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end

  def self.create(hash)
    dog=Dog.new(name: hash[:name], breed: hash[:breed])
    dog.save
  end

  def self.find_by_id(id)
    sql=<<-SQL
    SELECT *
    FROM dogs
    WHERE id=?
    SQL
    dog_row=DB[:conn].execute(sql,id).flatten
    dog=Dog.new_from_db(dog_row)
  end

  def self.new_from_db(row)
    Dog.new( name:row[1], breed:row[2], id:row[0])
  end

  def self.find_or_create_by(name:,breed:)
    sql=<<-SQL
    SELECT *
    FROM dogs
    WHERE name=? AND breed=?
    SQL
    dog_row=DB[:conn].execute(sql,name, breed).flatten
    if dog_row.empty?
      dog={:name => name, :breed => breed}
      Dog.create(dog)
    else
      dog=Dog.new_from_db(dog_row)
    end

  end

  def self.find_by_name(name)
    sql=<<-SQL
    SELECT *
    FROM dogs
    WHERE name=?
    SQL
    dog_row=DB[:conn].execute(sql,name).flatten
    dog=Dog.new_from_db(dog_row)
  end


end
