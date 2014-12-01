#!/usr/bin/ruby

# This file is part of Shortest-Path-Server.

# Copyright (c) 2014 Evan Berry 

# Shortest-Path-Server is free software: you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or (at your option) any later version.

# Shortest-Path-Server is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR 
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with 
# Shortest-Path-Server. If not, see http://www.gnu.org/licenses/.

class Node
  attr_reader :name
  attr_accessor :links

  def initialize name 
    @name = name
    @links = {}
  end

  def add_link node, cost
    @links[node] = cost
  end
end

# This check is to verify that the entry and terminal nodes exist
def preliminary_checks(entry, terminal, nodes)
  if nodes[entry] and nodes[terminal]
    true
  else
    false
  end
end

# This object is used to hold one route and its cost
class Cartographer
  attr_reader   :path,
                :total_cost

  def initialize(path, total_cost)
    @path = path
    @total_cost = total_cost
  end
end

# Explores the nodes provided for shortest path
class Explore
  attr_accessor :path
  def initialize(entry, terminal, nodes)
    @lowest_cost = 999999
    @path = nil
    @cartographs = []
    @children = []
    @nodes = nodes
    @terminal = terminal
    c = Cartographer.new([@nodes[entry].name], 0)
    @cartographs << c
    run
    if @path.nil? 
      @path = "no path from #{entry} to #{terminal}"
    else
      @path = @path.join("->") + " (#{@lowest_cost})"
    end
  end

  def run
   while @cartographs.count != 0 do
      recrute
      @cartographs = @children
      @children = []
      update
      prune
    end
  end

# each cartograph spawns children equal to the number
# of edges leading away from the current node
  def recrute
    @cartographs.each do |c|
      old_path = c.path
      old_cost = c.total_cost
      links = @nodes[old_path.last].links
      links.each do |name, cost| 
        new_path = []
        old_path.each {|n|new_path << n}
        new_path << name
        new_cost = old_cost 
        new_cost += cost
        new_cartographer = Cartographer.new(new_path, new_cost)
        @children << new_cartographer
      end
    end
  end

# updates overall lowest cost of successfull cartographs
# in preporation of the pruning stage
  def update
    @cartographs.each do |c|
      if c.total_cost <= @lowest_cost && c.path.last == @terminal
        @lowest_cost = c.total_cost
        @path = c.path
      end
    end
  end

# deletes all cartographs that have accumulated more cost 
# than the known lowest
  def prune
    @cartographs.each do |c|
      if c.total_cost > @lowest_cost
        @cartographs.delete c 
        next 
      end
    end 
  end
end
