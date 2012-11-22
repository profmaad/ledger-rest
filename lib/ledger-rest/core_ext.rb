class Hash
  def symbolize_keys
    hash = {}
    self.each_pair do |key, val|
      hash[key.to_sym] = val
    end
    hash
  end

  def symbolize_keys!
    self.keys.each do |key|
      self[key.to_sym] = self.delete key
    end
    self
  end

  def inject acc, &block
    self.each_pair do |key, val|
      acc = block.call acc, key, val
    end
    acc
  end
end
