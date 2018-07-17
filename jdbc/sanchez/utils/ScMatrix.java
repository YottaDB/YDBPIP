package sanchez.utils;

import java.util.Vector;

/**
 * ScMatrix is a utility  to handle matrix
 *
 * @author Quansheng Jia
 * @version 1.0  April 11 1999
 * @see ScMatrixEnumeration
 */


public final class ScMatrix extends sanchez.base.ScObject implements java.io.Serializable {
    Vector row = null;

    public ScMatrix() {
        row = new Vector();
    }


    //--------------------------------------------------
    // public methods
    //--------------------------------------------------

    /**
     * Adds the given element to this matrix at the specified row and column.
     *
     * @param r the row of the element to be added
     * @param c the column of the element to added
     * @param o the element to be added
     * @throws IllegalArgumentException if an element is already allocated
     *                                  at [r,c]
     * @see #updateElement
     * @see #removeElementAt
     */
    public void addElement(int r, int c, Object obj)
            throws IllegalArgumentException {
        Vector col = null;
        if (row.size() >= r + 1)
            col = (Vector) row.get(r);
        else {
            col = new Vector();
            row.add(r, col);
        }
        if (col.size() >= c + 1)
            col.setElementAt(obj, c);
        else col.add(c, obj);

    }

    /**
     * Adds or updates the element at the specified row and column, as needed.
     *
     * @param r the row of the element to be updated
     * @param c the column of the element to updated
     * @param o the new element
     * @see #addElement
     * @see #removeElementAt
     */
    public void updateElement(int r, int c, Object obj) {
        Vector col = null;
        try {
            col = (Vector) row.get(r);
        } catch (Exception e) {
            col = new Vector();
            row.add(r, col);
        }
        if (col.size() >= c + 1)
            col.setElementAt(obj, c);
        else col.add(c, obj);
    }

    /**
     * Removes all elements of the ScMatrix. The ScMatrix becomes empty.
     *
     * @see #addElement
     * @see #removeElementAt
     */
    public void removeAllElements() {
        row = null;
        row = new Vector();
    }

    /**
     * Returns the element at the specified row and column.
     *
     * @param r the row of the element to return
     * @param c the column of the element to return
     * @return the element at [r,c]
     * @throws ArrayIndexOutOfBoundsException if an invalid
     *                                        row and/or column was given
     */
    public Object elementAt(int r, int c)
            throws ArrayIndexOutOfBoundsException {
        Vector col = (Vector) row.get(r);
        //if (col==null) throw new ArrayIndexOutOfBoundsException();
        Object o = col.get(c);
        //if (o==null) throw new ArrayIndexOutOfBoundsException();
        return o;
    }

    /**
     * Deletes the element at the specified row and column.
     *
     * @param r the row of the element to remove
     * @param c the column of the element to remove
     * @throws ArrayIndexOutOfBoundsException if an invalid
     *                                        row and/or column was given
     */
    public void removeElementAt(int r, int c)
            throws ArrayIndexOutOfBoundsException {
        Vector col = (Vector) row.get(r);
        if (col == null) throw new ArrayIndexOutOfBoundsException();
        col.remove(c);
    }

    /**
     * Deletes all elements on the specified row.
     *
     * @param r the row of the elements to remove
     * @see #insertRow
     * @see #removeElementAt
     */
    public void removeRow(int r) {
        row.remove(r);
    }

    /**
     * Inserts a new row at the given location.
     * It does this by incrementing the row number of all elements with
     * row indexes >= given row number.
     *
     * @param r the number of the row to insert
     * @see #removeRow
     */
    public void insertRow(int r) {
        Vector col = new Vector();
        row.add(r, col);
    }

    /**
     * Returns the number of rows in the ScMatrix.
     */
    public int rows() {
        return row.size();
    }

    public Object getRow(int r) {
        return row.get(r);

    }

    public void addRow(Object o) {
        row.add(o);
    }

}