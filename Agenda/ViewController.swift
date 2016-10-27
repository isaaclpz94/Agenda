//
//  ViewController.swift
//  Agenda
//
//  Created by isaac on 27/10/16.
//  Copyright © 2016 isaac. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var contactos = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getAgenda()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAgenda()
    }
    
    // MARK: outlet & boton
    
    @IBAction func nuevo(_ sender: UIBarButtonItem) {
        //Creamos la alerta de dialogo para la entrada del nuevo contacto
        let alert = UIAlertController(title: "Nuevo Contacto", message: nil, preferredStyle: .alert)
        
        let guardar = UIAlertAction(title: "Guardar", style: .default) { (action: UIAlertAction) -> Void in
            let textField = alert.textFields![0]
            let textField2 = alert.textFields![1]
            self.guardarContacto(nombre: textField.text!, edad: Int(textField2.text!)!)
            self.tableView.reloadData()
        }
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel) { (action: UIAlertAction) in
            print("Cancelado")
        }
        
        alert.addTextField{ (textField) in
            textField.placeholder = "Nombre"
        }
        
        alert.addTextField{ (textField) in
            textField.placeholder = "Edad"
        }
        
        alert.addAction(guardar)
        alert.addAction(cancelar)
        present(alert, animated: true, completion: nil)
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Obtenemos el elemento en concreto
        let elementoNombre = contactos[indexPath.row].value(forKey: "nombre")
        let elementoEdad = contactos[indexPath.row].value(forKey: "edad")
        
        //Instanciamos la celda
        let celda = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        //Insertamos en la celda la información
        celda.textLabel?.text = elementoNombre as! String?
        celda.detailTextLabel?.text = String(describing: elementoEdad)
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let nombre = contactos[indexPath.row].value(forKey: "nombre") as! String
        
        let alert = UIAlertController(title: "Modificar", message: "Por favor, indique el nuevo nombre", preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Modificar", style: .default){(_) in
            let nameTextField = alert.textFields![0]
            self.updateContacto(index: indexPath.row, nuevoNombre: nameTextField.text!)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addTextField{ (textField) in
            textField.placeholder = nombre
        }
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            getContext().delete(contactos[indexPath.row])
            appDelegate.saveContext()
            
            contactos.remove(at: indexPath.row)
            tableView.reloadData()
            print("!Borrado¡")
        }
    }
    
    // MARK: Core Data
    
    func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func getAgenda(){
        //Creamos la peticion
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Agenda")
        
        do{
            //Obtenemos resultados a través de la petición y sacamos el resultado al array
            let resultados = try self.getContext().fetch(fetch as! NSFetchRequest<NSFetchRequestResult>)
            contactos = resultados as! [NSManagedObject]
        }catch{
            print("Error en la peticion \(error)")
        }
    }
    
    func guardarContacto(nombre: String, edad:Int){
        //Obtenemos el contexto con la función que hemos creado
        let context = getContext()
        
        //Lo insertamos
        let contacto = NSEntityDescription.insertNewObject(forEntityName: "Agenda", into: context)
        contacto.setValue(nombre, forKey: "nombre")
        contacto.setValue(edad, forKey: "edad")
        
        //Guardamos y añadimos al array el nuevo contacto
        do{
            try context.save()
            contactos.append(contacto)
            print("¡Guardado!")
        } catch let error as NSError{
            print("No se ha podido guardar \(error), \(error.userInfo)")
        }catch{
            print("Algo ha pasado")
        }
    }
    
    func updateContacto(index:Int, nuevoNombre: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        contactos[index].setValue(nuevoNombre, forKey: "nombre")
        
        appDelegate.saveContext()
        print("¡Actualizado!")
    }
}

