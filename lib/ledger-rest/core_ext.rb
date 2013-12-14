# -*- coding: utf-8 -*-
class Hash
  def symbolize_keys
    hash = {}
    each_pair do |key, val|
      hash[key.to_sym] = val
    end
    hash
  end

  def symbolize_keys!
    keys.each do |key|
      self[key.to_sym] = delete key
    end
    self
  end
end
