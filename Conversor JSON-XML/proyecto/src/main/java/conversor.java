/*******************\
 * Práctica de HSE *
 *******************/


import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.math.BigDecimal;
import java.util.List;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.json.simple.DeserializationException;
import org.json.simple.JsonArray;
import org.json.simple.JsonObject;
import org.json.simple.Jsoner;

/**
 * Clase principal
 */
public class conversor {
    
    /**
     * Muestra al usuario la forma de utilizar el programa
     */
    public static void showUse() {
        System.out.println("Use: ");
        System.out.println("   Export: java conversor export <source XML file> <target JSON file>");
        System.out.println("   Import: java conversor import <source JSON file> <target XML file>");
    }

    /**
     * Importar (convertir de JSON a XML)
     * @param srcFileName archivo JSON origen
     * @param tgtFileName archivo XML destino
     * @throws java.io.IOException Error de lectura escritura en fichero
     * @throws org.json.simple.DeserializationException Error de análisis JSON
     */
    public static void jsonToXml(String srcFileName, String tgtFileName) throws IOException, DeserializationException {
        //Obtiene el documento desde el archivo (parsing JSON)
        JsonArray nodoJSON = (JsonArray) Jsoner.deserialize(new FileReader(srcFileName));
        
        JsonObject pacienteJSON = (JsonObject) nodoJSON.get(0);
        
        //Obtiene el objeto paciente
        JsonObject datos_personalesJSON = (JsonObject) pacienteJSON.get("personal_data");
        
        //Crea el elemento raíz
        Element pacienteXML = new Element("paciente");
        
        //Crea cada elemento 'food'
        Element datos_personalesXML = new Element("datos_personales");
        
        //Obtiene cada propiedad del objeto, hace las conversiones necesarias
        //y las añade como elementos hijo de cada 'food', o como atributos
        String nombre = (String) datos_personalesJSON.get("name");
        datos_personalesXML.addContent(new Element("nombre").setText(nombre));
        int num_paciente = ((BigDecimal) datos_personalesJSON.get("id")).intValue();
        datos_personalesXML.addContent(new Element("num_paciente").setText(Integer.toString(num_paciente)));
        String fech_nacimiento = (String) datos_personalesJSON.get("birth_date");
        datos_personalesXML.addContent(new Element("fech_nacimiento").setText(fech_nacimiento));
        String estado_civil = (String) datos_personalesJSON.get("marital_status");
        String[] opciones_estado_civilXML = {"Soltero","Casado","Unión de hecho","Separado","Divorciado","Viudo",null};
        String[] opciones_estado_civilJSON = {"single","married","domestic partner","separated","divorced","widowed","unassigned"};
        int posicion = 6;
        for (int i=0; i< opciones_estado_civilJSON.length; i++) {
        	if (opciones_estado_civilJSON[i].equals(estado_civil)) {
        		posicion = i;
        	}
        }
        datos_personalesXML.addContent(new Element("estado_civil").setText(opciones_estado_civilXML[posicion]));
        
        //Añade el elemento al padre
        pacienteXML.addContent(datos_personalesXML);
        
        
        //Obtiene el objeto paciente
        JsonObject vacunaJSON = (JsonObject)((JsonArray) pacienteJSON.get("immunization")).get(0);
      
        //Crea cada elemento 'food'
        Element vacunaXML = new Element("vacuna");
        
        //Obtiene cada propiedad del objeto, hace las conversiones necesarias
        //y las añade como elementos hijo de cada 'food', o como atributos
        int codigo_CVX = ((BigDecimal) vacunaJSON.get("cvx_code")).intValue();
        vacunaXML.addContent(new Element("codigo_CVX").setText(Integer.toString(codigo_CVX)));          
        String fecha_administracion = (String) vacunaJSON.get("date");
        vacunaXML.addContent(new Element("fecha_administracion").setText(fecha_administracion));
        vacunaXML.addContent(new Element("hora_administracion").setText("00:00:00"));
        String cantidad_administrada = (String) vacunaJSON.get("amount");
        Element cantidad_administradaXML = new Element("cantidad_administrada");
        vacunaXML.addContent(cantidad_administradaXML.setText(cantidad_administrada));
        cantidad_administradaXML.setAttribute("unidad","mg");
        String expiracion = (String) vacunaJSON.get("expiration_date");
        vacunaXML.addContent(new Element("expiracion").setText(expiracion));
        String fabricante = (String) vacunaJSON.get("manufacturer");
        vacunaXML.addContent(new Element("fabricante").setText(fabricante));
        String lote = (String) vacunaJSON.get("lot_number");
        vacunaXML.addContent(new Element("lote").setText(lote));
        String observaciones = (String) vacunaJSON.get("notes");
        Element observacionesXML = new Element("observaciones");
        vacunaXML.addContent(observacionesXML.setText(observaciones));
        observacionesXML.setAttribute("idioma", "ing");
        
       //Añade el elemento al padre
        pacienteXML.addContent(vacunaXML);
        
        
      //Obtiene el objeto paciente
        JsonArray visitasJSON = (JsonArray) pacienteJSON.get("visit_history");
	    
        for (int i=0; i<visitasJSON.size(); i++) {
        	//
        	JsonObject visitaJSON = (JsonObject) visitasJSON.get(i);
        	
	        //Crea cada elemento 'food'
	        Element visitaXML = new Element("visita");
	        
	        //Obtiene cada propiedad del objeto, hace las conversiones necesarias
	        //y las añade como elementos hijo de cada 'food', o como atributos
	        String fecha = (String) visitaJSON.get("date");
	        visitaXML.addContent(new Element("fecha").setText(fecha));
	        JsonArray incidenciasJSON = (JsonArray) visitaJSON.get("issues");
	        for (int j=0; j<incidenciasJSON.size(); j++) {
	        	visitaXML.addContent(new Element("incidencias").setText((String) incidenciasJSON.getString(j)));
	        }
	        String motivo = (String) visitaJSON.get("reason");
	        visitaXML.addContent(new Element("motivo").setText(motivo));
	        String facultativo = (String) visitaJSON.get("provider");
	        visitaXML.addContent(new Element("facultativo").setText(facultativo));
	        String seguro = (String) visitaJSON.get("insurance");
	        visitaXML.addContent(new Element("seguro").setText(seguro));
	        
        
	        //Añade el elemento al padre
	        pacienteXML.addContent(visitaXML);
        }        
        
        //Genera el archivo XML
        Writer output = new FileWriter(tgtFileName);
        XMLOutputter outputter = new XMLOutputter();
        outputter.setFormat(Format.getPrettyFormat());
        outputter.output(new Document().addContent(pacienteXML), output);
        output.close();
    }
    
    /**
     * Exportar (convertir de XML a JSON)
     * @param srcFileName archivo XML origen
     * @param tgtFileName archivo JSON destino
     * @throws java.io.IOException Error de lectura escritura en fichero
     * @throws org.jdom2.JDOMException Error de análisis XML
     */
    public static void xmlToJson(String srcFileName, String tgtFileName) throws IOException, JDOMException {
        //Obtiene el documento desde el archivo (parsing XML)
        SAXBuilder builder = new SAXBuilder();
        Document document = (Document) builder.build(new File(srcFileName));
 
        //Obtiene el nodo raíz
        Element pacienteXML = document.getRootElement();
 
        //Crea la lista nodo
        JsonArray nodoJSON = new JsonArray();
        
        //Crea el objeto paciente, que irá dentro del nodoJSON
        JsonObject pacienteJSON = new JsonObject();
        
        //Obtiene el elemento del XML de datos_personales
        Element datos_personalesXML = (Element) pacienteXML.getChildren("datos_personales").get(0);
        
        //Crea un objeto JSON para representar los datos_personales
        JsonObject datos_personalesJSON = new JsonObject();
        
        
        //Obtienen los demás datos del cada item, haciendo las oportunas conversiones
        //y los añade como propiedades de los objetos
        int num_paciente = Integer.parseInt(datos_personalesXML.getChildTextTrim("num_paciente"));
        datos_personalesJSON.put("id", num_paciente);
        String nombre = datos_personalesXML.getChildTextTrim("nombre");
        datos_personalesJSON.put("name", nombre);
        String fech_nacimiento = datos_personalesXML.getChildTextTrim("fech_nacimiento");
        datos_personalesJSON.put("birth_date", fech_nacimiento);
        String estado_civil = datos_personalesXML.getChildTextTrim("estado_civil");
        String[] opciones_estado_civil = {"Soltero","Casado","Unión de hecho","Separado","Divorciado","Viudo"};
        String[] opciones_estado_civilJSON = {"single","married","domestic partner","separated","divorced","widowed","unassigned"};
        
        int posicion = 6;
        for (int i=0; i< opciones_estado_civil.length; i++) {
        	if (opciones_estado_civil[i].equals(estado_civil)) {
        		posicion = i;
        	}
        }
        datos_personalesJSON.put("marital_status", opciones_estado_civilJSON[posicion]);
        
        //Añade el objeto datos_personales al objeto pacienteJSON
        pacienteJSON.put("personal_data", datos_personalesJSON);
        
        
        
        

        //Obtiene el elemento del XML de datos_personales
        Element vacunaXML = (Element) pacienteXML.getChildren("vacuna").get(0);
        
        //Crea un array de objetos para representar las vacunas
        JsonArray vacunasJSON = new JsonArray();
        
        //Crea un objeto para representar las vacunas
        JsonObject vacunaJSON = new JsonObject();
        
        //Obtienen los demás datos del cada item, haciendo las oportunas conversiones
        //y los añade como propiedades de los objetos
        int codigo_CVX = Integer.parseInt(vacunaXML.getChildTextTrim("codigo_CVX"));
        vacunaJSON.put("cvx_code", codigo_CVX);
        String fecha_administracion = vacunaXML.getChildTextTrim("fecha_administracion");
        vacunaJSON.put("date", fecha_administracion);
        String cantidad_administrada = vacunaXML.getChildTextTrim("cantidad_administrada");
        vacunaJSON.put("amount", cantidad_administrada);
        String expiracion = vacunaXML.getChildTextTrim("expiracion");
        vacunaJSON.put("expiration_date", expiracion);
        String fabricante = vacunaXML.getChildTextTrim("fabricante");
        vacunaJSON.put("manufacturer", fabricante);
        String lote = vacunaXML.getChildTextTrim("lote");
        vacunaJSON.put("lot_number", lote);
        String observaciones = vacunaXML.getChildTextTrim("observaciones");
        vacunaJSON.put("notes", observaciones);
        
        //Añade el objeto vacunaJSON al array vacunasJSON
        vacunasJSON.add(vacunaJSON);
        
        //Añade el array de vacunasJSON creado al objeto pacienteJSON
        pacienteJSON.put("immunization", vacunasJSON);
        
        
        
        
        //Obtiene la lista de visitas
        List visitasXML = pacienteXML.getChildren("visita");
        
        //Crea un array de visitasJSON
        JsonArray visitasJSON = new JsonArray();
        
        for (int i=0; i<visitasXML.size(); i++) {
        	//Obtiene el elemento del XML de visita
            Element visitaXML = (Element) visitasXML.get(i);
            
            //Crea un objeto JSON para representar la visita
            JsonObject visitaJSON = new JsonObject();
            
          //Obtienen los demás datos del cada item, haciendo las oportunas conversiones
            //y los añade como propiedades de los objetos
            String fecha = visitaXML.getChildTextTrim("fecha");
            visitaJSON.put("date", fecha);
            
            List incidenciasXML = visitaXML.getChildren("incidencias");
            JsonArray incidenciasJSON = new JsonArray();
            
            for (int j=0; j<incidenciasXML.size(); j++) {
            	Element incidenciaXML = (Element) incidenciasXML.get(j);
            	incidenciasJSON.add(incidenciaXML.getValue());
            }
            visitaJSON.put("issues", incidenciasJSON);
            String motivo = visitaXML.getChildTextTrim("motivo");
            visitaJSON.put("reason", motivo);
            String facultativo = visitaXML.getChildTextTrim("facultativo");
            visitaJSON.put("provider", facultativo);
            String seguro = visitaXML.getChildTextTrim("seguro");
            visitaJSON.put("insurance", seguro);
            
            //Añade el objeto creado al array visitasJSON
            visitasJSON.add(visitaJSON);
        }
        
        //Añade el array visitasJSON al objeto pacienteJSON
        pacienteJSON.put("visit_history",visitasJSON);
        
        //Añade el objeto pacienteJSON al array nodo
        nodoJSON.add(pacienteJSON);
        
        System.out.println(nodoJSON.toJson());
            
        //Genera el archivo JSON
        Writer output = new FileWriter(tgtFileName);
        nodoJSON.toJson(output);
        output.close();
    }
    
    /**
     * Función principal
     * @param args parámetros en línea de órdenes
     * @throws java.io.IOException Error de lectura escritura en fichero
     * @throws org.jdom2.JDOMException Error de análisis XML
     * @throws org.json.simple.DeserializationException Error de análisis JSON
     */
    public static void main(String[] args) throws IOException, JDOMException, DeserializationException {
        if (args.length < 3) {
            showUse();
        } else {
            switch (args[0]) {
                case "export":
                    xmlToJson(args[1], args[2]);
                    break;
                case "import":
                    jsonToXml(args[1], args[2]);
                    break;
                default:
                    showUse();
            }
        }
    }
}
