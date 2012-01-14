class Logger
  def initialize(file_name = "log.txt")
    @log_file = File.open("../#{file_name}", 'w')
    @log_file.write "Created logger\n"
  end

  def log(msg)
    @log_file.write(msg + "\n")
  end
end