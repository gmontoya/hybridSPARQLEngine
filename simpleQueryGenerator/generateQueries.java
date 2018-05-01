import java.util.*;
import java.io.*;

import com.hp.hpl.jena.query.QuerySolution;
import com.hp.hpl.jena.query.ResultSet;
import com.hp.hpl.jena.rdf.model.RDFNode;
import com.hp.hpl.jena.query.QueryExecution;
import com.hp.hpl.jena.query.QueryExecutionFactory;
import com.hp.hpl.jena.query.Query;
import com.hp.hpl.jena.query.QueryFactory;
import com.hp.hpl.jena.rdf.model.Model;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.util.FileManager;
import com.hp.hpl.jena.sparql.engine.http.QueryEngineHTTP;
import com.hp.hpl.jena.graph.Triple;
import com.hp.hpl.jena.rdf.model.Literal;

import com.hp.hpl.jena.graph.Node;
import com.hp.hpl.jena.sparql.algebra.*;
import com.hp.hpl.jena.sparql.syntax.*;

class generateQueries {

    public static void main (String args[]) throws Exception {

        String endpoint = args[0];
        String templateFile = args[1];
        int number = Integer.parseInt(args[2]);
        String folder = args[3];
        int minNumResults = Integer.parseInt(args[4]);
        int maxNumResults = Integer.parseInt(args[5]);
        String prefix = args[6];

        List<String[]> triples = getTriples(templateFile);
        generateQueries(endpoint, triples, number, folder, minNumResults, maxNumResults, prefix);
    }

    public static void generateQueries(String endpoint, List<String[]> triples, int number, String folder, int minNR, int maxNR, String prefix) throws Exception {

        String query = getBody(triples);
        Vector<String> values = executeGetValues(endpoint, "?k", query, number, minNR, maxNR);
        int i = 0;
        for (String value : values) {
            String queryTmp = query.replaceAll("\\?k", value);
           //System.out.println(queryTmp);
            Query q = QueryFactory.create(getSelectQuery(queryTmp));
            String queryName = prefix+i;
            storeQuery(q, queryName, folder);
            i++;
        }
        System.out.println(i+" queries generated");
    }

    public static Vector<String> executeGetValues(String endpoint, String var, String body, int number, int minNR, int maxNR) {

        Vector<String> instantiations = new Vector<String>();
        String queryD = "SELECT DISTINCT "+var+" (COUNT (*) AS ?c) WHERE {  "+body + " } GROUP BY "+var+" \n ORDER BY DESC(?c) \n LIMIT 100";
        //System.out.println(queryD);

        int i = 0;
        int o = 0;
        find: while (i<number) {
            String queryT = queryD + " \n OFFSET "+o;
            //System.out.println(queryT);
            QueryEngineHTTP queryExec = new QueryEngineHTTP(endpoint, queryT);
            ResultSet rs = queryExec.execSelect();
            while (rs.hasNext()) {
                QuerySolution binding = rs.nextSolution();
                RDFNode n = binding.get("?c");
                int num = n.asLiteral().getInt();
                if (num > minNR && num <= maxNR) {
                    RDFNode v = binding.get(var);
                    String value = getString(v);
                    instantiations.add(value);
                    i++;
                }
                if (num <= minNR ||  i >= number) {
                    queryExec.close();
                    break find;
                }
            }
            o = o + 100;
            queryExec.close();
        }

        return instantiations;
    }

    public static String getString(Node n) {
        String p = "";
        if (n.isVariable()) {
            p="?"+n.getName();
        } else if (n.isURI()) {
            p = "<"+n.getURI().toString()+">";
        } else if (n.isLiteral()) {
            p = "\""+n.getLiteralLexicalForm()+"\"";
            String dt = n.getLiteralDatatypeURI();
            String lg = n.getLiteralLanguage();
            if (lg != null && !lg.equals("")) {
                p = p + "@"+lg;
            }
            if (dt != null && !dt.equals("")) {
                p = p + "^^<" + dt+">";
            }
        }
        return p;
    }

    public static List<String[]> getTriples(String queryFile) {

        Vector<String[]> triples = new Vector<String[]>();

        Query query = QueryFactory.read(queryFile);
        Op op = Algebra.compile(query);
        myTriplePatternVisitor mv = new myTriplePatternVisitor();
        OpWalker ow = new OpWalker();
        ow.walk(op, mv);
        List<Triple> ts = mv.getTriples();

        for (Triple t : ts) {
            String[] components = {getString(t.getSubject()), getString(t.getPredicate()), getString(t.getObject())};
            triples.add(components);
        }
        return triples;
    }

    public static String getString(RDFNode n) {
        String p = "";
        if (n.isResource()) {
            p = "<"+n.asResource().toString()+">";
        } else if (n.isLiteral()) {
            Literal l = n.asLiteral();
            p = "\""+l.getLexicalForm()+"\"";
            String dt = l.getDatatypeURI();
            String lg = l.getLanguage();
            if (lg != null && !lg.equals("")) {
                p = p + "@"+lg;
            }
            if (dt != null && !dt.equals("")) {
                p = p + "^^<" + dt+">";
            }
        }
        return p;
    }
    public static void storeQuery(Query q, String queryName, String queriesFolder) throws Exception {

        String newName = queriesFolder+"/"+queryName;
        BufferedWriter output = new BufferedWriter(new OutputStreamWriter(
                                new FileOutputStream(newName), "UTF-8"));
        String s = q.toString();
        output.write(s);
        output.newLine();
        output.flush();
        output.close(); 
    }

    public static String getSelectQuery(String body) {

        String varsStr ="*";

        return "SELECT DISTINCT "+varsStr+" WHERE { "+body+" } ";
    }

    public static String getBody(List<String[]> triples) {

        String body = "";
        for (String[] t : triples) {
            body += "  "+t[0]+"  "+t[1]+"  "+t[2]+" .\n";
        }
        return body;
    }
}
