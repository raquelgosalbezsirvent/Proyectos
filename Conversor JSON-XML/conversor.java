/*******************\
 * Práctica de HSE *
 *******************/
package program;

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
        JsonArray comidas = (JsonArray) Jsoner.deserialize(new FileReader(srcFileName));
            
        //Crea el elemento raíz
        Element breakfastMenu = new Element("breakfast_menu");
        
        //Recorre el array de comidas
        for (int i = 0; i < comidas.size(); i++) {
            //Obtiene cada objeto 'comida'
            JsonObject comida = (JsonObject) comidas.get(i);
            
            //Crea cada elemento 'food'
            Element food = new Element("food");
            
            //Obtiene cada propiedad del objeto, hace las conversiones necesarias
            //y las añade como elementos hijo de cada 'food', o como atributos
            String nombre = (String) comida.get("nombre");
            food.addContent(new Element("name").setText(nombre));
            String precio = (String) comida.get("precio");
            food.addContent(new Element("price").setText(precio));
            String comentarios = (String) comida.get("comentarios");
            food.addContent(new Element("description").setText(comentarios));
            int calorias = ((BigDecimal) comida.get("calorias")).intValue();
            food.addContent(new Element("calories").setText(Integer.toString(calorias)));
            String identificador = (String) comida.get("identificador");
            food.setAttribute("id", identificador);
            
            //Añade el elemento al padre
            breakfastMenu.addContent(food);
        }            

        //Genera el archivo XML
        Writer output = new FileWriter(tgtFileName);
        XMLOutputter outputter = new XMLOutputter();
        outputter.setFormat(Format.getPrettyFormat());
        outputter.output(new Document().addContent(breakfastMenu), output);
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
        Element breakfastMenu = document.getRootElement();
 
        //Crea una lista de objetos JSON para incluir cada 'comida'
        JsonArray comidas = new JsonArray();

        //Obtiene la lista de elementos hijo con una determinada etiqueta
        List list = breakfastMenu.getChildren("food");
 
        //Recorre la lista de hijos
        for (int i = 0; i < list.size(); i++)
        {
            //Obtiene cada elemento 'food'
            Element food = (Element) list.get(i);
            
            //Crea un objeto JSON para representar la 'comida'
            JsonObject comida = new JsonObject();
             
            //Obtiene el atributo 'id' de cada 'food' y se añade al objeto 'comida'
            String id = food.getAttributeValue("id");
            comida.put("identificador", id);
 
            //Obtienen los demás datos del cada 'food', haciendo las oportunas conversiones
            //y los añade como propiedades de los objetos
            String name = food.getChildTextTrim("name");
            comida.put("nombre", name);
            String price = food.getChildTextTrim("price");
            comida.put("precio", price);
            String description = food.getChildTextTrim("description");
            comida.put("comentarios", description);
            int calories = Integer.parseInt(food.getChildTextTrim("calories"));
            comida.put("calorias", calories);
            
            //Añade el objeto creado a la lista
            comidas.add(comida);
        }
        System.out.println(comidas.toJson());
            
        //Genera el archivo JSON
        Writer output = new FileWriter(tgtFileName);
        comidas.toJson(output);
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
