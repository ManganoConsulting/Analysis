import java.util.Enumeration;
// import java.awt.dnd.*;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JTree;
// import javax.swing.tree.DefaultMutableTreeNode;
// import javax.swing.tree.DefaultTreeModel;
// import javax.swing.tree.TreeSelectionModel;
import java.awt.BorderLayout;
import java.awt.datatransfer.*;
import java.awt.*;
import java.io.*;
import java.util.*;
import javax.activation.*;
import javax.swing.*;
import javax.swing.tree.*;

import java.util.Vector;


public class SimViewTreePanel extends JPanel {
    private JPanel panel;
    private JTree tree;
    private DefaultTreeModel treeModel;
    
    public SimViewTreePanel() 
    {
        panel = new JPanel();
    }
    
    public SimViewTreePanel(String[] slist) 
    {
        
        DefaultMutableTreeNode root = new DefaultMutableTreeNode("ROOT");

        DefaultTreeModel treeModel = new DefaultTreeModel(root);

        JTree tree = new JTree(treeModel);  
        tree.setDragEnabled(true);
        tree.getSelectionModel().setSelectionMode(TreeSelectionModel.DISCONTIGUOUS_TREE_SELECTION);
        tree.setTransferHandler(new TransferHandler() {

            @Override
            public boolean importData(TransferSupport support)
            {
                if (!canImport(support))
                {
                    return false;
                }

                JTree.DropLocation dl = (JTree.DropLocation) support.getDropLocation();

                TreePath path = dl.getPath();
                int childIndex = dl.getChildIndex();

                String data;
                try
                {
                    data = (String) support.getTransferable().getTransferData(DataFlavor.stringFlavor);
                }
                catch (UnsupportedFlavorException e)
                {
                    return false;                   
                }
                catch (IOException e)
                {
                    return false;                   
                }

//                 if (childIndex == -1)
//                 {
//                     childIndex = tree.getModel().getChildCount(path.getLastPathComponent());
//                 }
// 
//                 DefaultMutableTreeNode newNode = new DefaultMutableTreeNode(data);
//                 DefaultMutableTreeNode parentNode = (DefaultMutableTreeNode) path.getLastPathComponent();
//                 treeModel.insertNodeInto(newNode, parentNode, childIndex);
// 
//                 tree.makeVisible(path.pathByAddingChild(newNode));
//                 tree.scrollRectToVisible(tree.getPathBounds(path.pathByAddingChild(newNode)));

                return true;
            }

            public boolean canImport(TransferSupport support)
            {
                if (!support.isDrop())
                {
                    return false;                   
                }

                support.setShowDropLocation(true);
                if (!support.isDataFlavorSupported(DataFlavor.stringFlavor))
                {
                    System.err.println("only string is supported");
                    return false;                   
                }

                JTree.DropLocation dl = (JTree.DropLocation) support.getDropLocation();

                TreePath path = dl.getPath();

                if (path == null)
                {
                    return false;                   
                }
                return true;
            }                       
        }); 
        
        for (String data : slist) {
            buildTreeFromString(treeModel, data);
        }      
        
        this.add(tree);     

        
        
        // Make the root node invisible
        tree.expandRow(0);
        tree.setRootVisible(false);
        tree.setShowsRootHandles(true);
 
    }
    

    /**
     * Builds a tree from a given forward slash delimited string.
     * 
     * @param model The tree model
     * @param str The string to build the tree from
     */
    private void buildTreeFromString(final DefaultTreeModel model, final String str) {
        // Fetch the root node
        DefaultMutableTreeNode root = (DefaultMutableTreeNode) model.getRoot();

        // Split the string around the delimiter
        String [] strings = str.split("/");

        // Create a node object to use for traversing down the tree as it 
        // is being created
        DefaultMutableTreeNode node = root;

        // Iterate of the string array
        for (String s: strings) {
            // Look for the index of a node at the current level that
            // has a value equal to the current string
            int index = childIndex(node, s);

            // Index less than 0, this is a new node not currently present on the tree
            if (index < 0) {
                // Add the new node
                DefaultMutableTreeNode newChild = new DefaultMutableTreeNode(s);
                node.insert(newChild, node.getChildCount());
                node = newChild;
            }
            // Else, existing node, skip to the next string
            else {
                node = (DefaultMutableTreeNode) node.getChildAt(index);
            }
        }          
    }

    /**
     * Returns the index of a child of a given node, provided its string value.
     * 
     * @param node The node to search its children
     * @param childValue The value of the child to compare with
     * @return The index
     */
    private int childIndex(final DefaultMutableTreeNode node, final String childValue) {
        Enumeration<DefaultMutableTreeNode> children = node.children();
        DefaultMutableTreeNode child = null;
        int index = -1;

        while (children.hasMoreElements() && index < 0) {
            child = children.nextElement();

            if (child.getUserObject() != null && childValue.equals(child.getUserObject())) {
                index = node.getIndex(child);
            }
        }

        return index;
    }
    
//     public static void main(String[] args) {
//         System.out.println("Im Here");
//         new PathTest(args);
//     }
}

// class TreeTransferHandler extends TransferHandler {
//   public static final DataFlavor FLAVOR = new ActivationDataFlavor(
//     DefaultMutableTreeNode[].class,
//     DataFlavor.javaJVMLocalObjectMimeType,
//     "Array of DefaultMutableTreeNode");
//   @Override protected Transferable createTransferable(JComponent c) {
//     JTree source = (JTree) c;
//     TreePath[] paths = source.getSelectionPaths();
//     DefaultMutableTreeNode[] nodes = new DefaultMutableTreeNode[paths.length];
//     for (int i = 0; i < paths.length; i++) {
//       nodes[i] = (DefaultMutableTreeNode) paths[i].getLastPathComponent();
//     }
//     return new DataHandler(nodes, FLAVOR.getMimeType());
//   }
//   @Override public int getSourceActions(JComponent c) {
//     return TransferHandler.COPY;
//   }
// }