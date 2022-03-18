import java.awt.BorderLayout;
import java.awt.EventQueue;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.border.EmptyBorder;
import javax.swing.JTextArea;
import javax.swing.ScrollPaneConstants;
import javax.swing.JComboBox;
import javax.swing.DefaultComboBoxModel;
import java.awt.Font;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JButton;
import java.awt.Color;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import javax.swing.SwingConstants;

@SuppressWarnings("serial")
public class ResumenAnual extends JFrame {

	private JPanel contentPane;
	private static Connection con = conect();

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					ResumenAnual frame = new ResumenAnual();
					frame.setVisible(true);
					
			//Sobreescribimos windowClosing para que cierre la conexion al cerrar el frame;
					frame.addWindowListener(new WindowAdapter() {
						public void windowClosing(WindowEvent ev) {
								try {
									con.close();
									System.out.println("Conexion Cerrada");
								} catch (SQLException e) {
									
									e.printStackTrace();
								}
								System.exit(0);
							}
						});
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}


	/**
	 * Create the frame.
	 */
	public ResumenAnual() {
		setTitle("Resumen Anual FreePelos");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 1117, 540);
		contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		contentPane.setLayout(null);
		
		JTextArea textArea = new JTextArea();
		textArea.setEditable(false);
		textArea.setFont(new Font("Times New Roman", Font.BOLD, 16));
		textArea.setTabSize(20);
		textArea.setBounds(42, 212, 1013, 251);
		JScrollPane scroll = new JScrollPane(textArea);
		scroll.setBounds(10, 212, 1083, 280);
		scroll.setVerticalScrollBarPolicy(ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);
		contentPane.add(scroll);
		
		JComboBox cBoxInicio = new JComboBox();
		cBoxInicio.setToolTipText("");
		cBoxInicio.setFont(new Font("Tahoma", Font.BOLD, 19));
		cBoxInicio.setModel(new DefaultComboBoxModel(new String[] {"2018", "2019", "2020", "2021"}));
		cBoxInicio.setSelectedIndex(1);
		cBoxInicio.setBounds(176, 78, 135, 38);
		contentPane.add(cBoxInicio);
		
		JLabel lblInicio = new JLabel("Elige Intervalo");
		lblInicio.setToolTipText("");
		lblInicio.setFont(new Font("Tahoma", Font.PLAIN, 18));
		lblInicio.setBounds(42, 34, 135, 22);
		contentPane.add(lblInicio);
		
		JLabel lblDesde = new JLabel("DESDE");
		lblDesde.setToolTipText("");
		lblDesde.setFont(new Font("Tahoma", Font.PLAIN, 18));
		lblDesde.setBounds(95, 87, 74, 22);
		contentPane.add(lblDesde);
		
		JLabel lblHasta = new JLabel("HASTA");
		lblHasta.setToolTipText("");
		lblHasta.setFont(new Font("Tahoma", Font.PLAIN, 18));
		lblHasta.setBounds(370, 86, 68, 22);
		contentPane.add(lblHasta);
		
		JComboBox cBoxFin = new JComboBox();
		cBoxFin.setToolTipText("");
		cBoxFin.setModel(new DefaultComboBoxModel(new String[] {"2018", "2019", "2020", "2021"}));
		cBoxFin.setSelectedIndex(1);
		cBoxFin.setFont(new Font("Tahoma", Font.BOLD, 19));
		cBoxFin.setBounds(451, 78, 135, 38);
		contentPane.add(cBoxFin);
		
		JLabel lblNewLabel = new JLabel("FECHA");
		lblNewLabel.setForeground(Color.DARK_GRAY);
		lblNewLabel.setFont(new Font("Tahoma", Font.PLAIN, 16));
		lblNewLabel.setBounds(42, 178, 97, 22);
		contentPane.add(lblNewLabel);
		
		JLabel lblCliente = new JLabel("CLIENTE");
		lblCliente.setForeground(Color.DARK_GRAY);
		lblCliente.setFont(new Font("Tahoma", Font.PLAIN, 16));
		lblCliente.setBounds(297, 178, 87, 22);
		contentPane.add(lblCliente);
		
		JLabel lblServicio = new JLabel("SERVICIO");
		lblServicio.setForeground(Color.DARK_GRAY);
		lblServicio.setFont(new Font("Tahoma", Font.PLAIN, 16));
		lblServicio.setBounds(540, 179, 145, 22);
		contentPane.add(lblServicio);
		
		JLabel lblAnyos = new JLabel("");
		lblAnyos.setHorizontalAlignment(SwingConstants.CENTER);
		lblAnyos.setForeground(Color.DARK_GRAY);
		lblAnyos.setFont(new Font("Tahoma", Font.PLAIN, 16));
		lblAnyos.setBounds(713, 145, 295, 22);
		contentPane.add(lblAnyos);
		
		JLabel lblResultado = new JLabel("");
		lblResultado.setForeground(Color.DARK_GRAY);
		lblResultado.setFont(new Font("Tahoma", Font.BOLD, 16));
		lblResultado.setBounds(729, 178, 326, 22);
		contentPane.add(lblResultado);
		
		JButton btnMostrar = new JButton("MOSTRAR DATOS");
		btnMostrar.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				int inicio = Integer.parseInt(cBoxInicio.getSelectedItem().toString());
				int fin = Integer.parseInt(cBoxFin.getSelectedItem().toString());
				if(fin >= inicio) {
					mostrarDatos(textArea, inicio, fin, lblResultado);
					if (inicio == fin)lblAnyos.setText("DATOS DE " + inicio );
					else lblAnyos.setText("DATOS ENTRE " + inicio + " Y " + fin);

				}else {
					JOptionPane.showMessageDialog(null, "El año de inicio no puede ser superior al año de fin",
							 "ERROR", JOptionPane.ERROR_MESSAGE);
				}
			}
		});
		btnMostrar.setFont(new Font("Tahoma", Font.BOLD, 20));
		btnMostrar.setBounds(703, 39, 311, 77);
		contentPane.add(btnMostrar);
	}
	
	public void mostrarDatos(JTextArea area, int ini, int fin, JLabel res) {
		
		String[] filas;
		ArrayList<String[]> allElements = new ArrayList<String[]>();
		area.setText("");
		
		try {
			Statement st = con.createStatement();
			ResultSet rs;
			String consulta = "SELECT get_registros ('" + ini + "', '" + fin + "')";
			rs = st.executeQuery(consulta);
			while (rs.next()) {
				String nombre = rs.getString("get_registros");
				String[] arrayValores = nombre.split("\\>>>>>>>>>>>>");
				res.setText(arrayValores[1]);
				filas = arrayValores[0].split("\\----");
				
				for (int i = 0; i<filas.length; i++) {
					
						String[] e = filas[i].split("\\;");
						allElements.add(e);
				
				}
				for (String[] s : allElements) {

					String forText = "";
					
					for (int i = 0; i < s.length; i++) {
			
						forText += s[i] + "\t";
					}
					forText += "\n";
					if (!forText.contains(" => 0.0€")) area.append(forText);
				}
			}
			System.out.println(rs);
		} catch (SQLException e) {
		
			e.printStackTrace();
		}
	}

	public static Connection conect() {
		Connection con = null;
		String url = "jdbc:postgresql://localhost:5432/";
		String db = "A_FreePelos";
		@SuppressWarnings("unused")
		String driver = "com.postgres.cj.jdbc.Driver";
		String user = "postgres";
		String pass = "Sparky_1993";
		
		try {
			con = DriverManager.getConnection(url + db, user, pass);
			System.out.println("Conexion realizada");
		}catch (Exception e) {
			System.out.print(e);
		}
		return con;
	}
}
