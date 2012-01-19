#include "common.hpp"

#ifndef FACTOR_GRAPH_HPP
#define FACTOR_GRAPH_HPP

namespace FactorGraph{
  class Variable{
    ///\brief Return the name of this variable
    virtual std::string name() const{ return m_name; }
    
    ///\brief Return the number of values that this discrete variable can take
    virtual unsigned num_vals() const{ return m_num_vals; }
  };

  ///\brief A discrete variable in a factor graph
  class DiscreteVariable: public Variable{
    ///\brief The name of this variable
    std::string m_name;
    
    ///\brief The number of values that this discrete variable can take
    ///on
    unsigned m_num_vals;

  public:
    ///\brief Create a DiscreteVariable named \a name that can take on
    ///\a num_vals values
    ///
    ///\param name The name of the new variable
    ///
    ///\param num_vals the number of values the variable can take on
    DiscreteVariable(std::string name, unsigned num_vals)
      :m_name(name), m_num_vals(num_vals){}
    
    ///\brief Create a DiscreteVariable named \a base_name \a number that can
    ///take on \a num_vals values 
    ///
    ///To create a variable named "a1" that takes on 256 values, you
    ///call \code DiscreteVariable("a",1, 256) \endcode
    ///
    ///\param base_name The base-name of the new variable
    ///
    ///\param index The index of the new variable
    ///
    ///\param num_vals the number of values the variable can take on
    DiscreteVariable(std::string base_name, unsigned index, unsigned num_vals)
      :m_name(base_name+GClasses::to_str(index)), m_num_vals(num_vals){}
    
    ///\brief Return the name of this variable
    virtual std::string name() const{ return m_name; }
    
    ///\brief Return the number of values that this discrete variable can take
    virtual unsigned num_vals() const{ return m_num_vals; }
  };



  class Factor{
  };

  class Graph{
  };
};
#endif



