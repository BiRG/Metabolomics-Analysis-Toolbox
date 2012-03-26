package com.jmatio.types;

/**
 * GenericArrayCreator object can create arrays
 * @author Wojciech Gradkowski (<a href="mailto:wgradkowski@gmail.com">wgradkowski@gmail.com</a>)
 *
 * @param <T> The type of the array to create
 */
public interface GenericArrayCreator<T>
{
    T[] createArray(int m, int n);
}
