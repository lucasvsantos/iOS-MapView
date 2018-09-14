//
//  ViewController.swift
//  Mapa
//
//  Created by Usuário Convidado on 14/09/2018.
//  Copyright © 2018 Usuário Convidado. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    var locationManage = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Mostrar a localizacao do usuario
        mapView.showsUserLocation = true
        //Rastrear a localizacao do usuario
        mapView.userTrackingMode = .follow
        //Definindo o delegate do MapView
        mapView.delegate = self
        //Definindo a delegate (classe que responde) da searchBar
        searchBar.delegate = self
        requestAuthorization()
    }
    
    //Solicitando autorizacao do usuario para o o uso da sua localizacao
    func requestAuthorization(){
        locationManage.desiredAccuracy = kCLLocationAccuracyBest
        //Solicita a autorizacao somente com o app em uso
        locationManage.requestWhenInUseAuthorization()
    }
    
    
    
}

extension ViewController: UISearchBarDelegate{
    //Implementando metodo disparado pelo botao search da search bar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Retirando o foco da searchNar (escondendo o teclado)
        searchBar.resignFirstResponder()
        //Criando objeto que configura uma pesquisa de pontos de interesse
        let request = MKLocalSearchRequest()
        //Configurando a regiao do mapa onde a pesquisa vai ser feita
        request.region = mapView.region
        //Definindo o que sera pesquisado
        request.naturalLanguageQuery = searchBar.text
        //Criando o objeto que realiza a pesquisa
        let search = MKLocalSearch(request: request)
        
        //Realizando a pesquisa
        search.start { (response, error) in
            if error == nil {//Nao teve erro na pesquisa
                guard let response = response else { return }
                
                //Remover as annotations previsamente adicionadas
                self.mapView.removeAnnotations(self.mapView.annotations)
                
                //Varrendo todos os pontos de interesse trazidos pela pesquisa
                for item in response.mapItems {
                    //Criando uma annotation
                    let annotation = MKPointAnnotation()
                    
                    //Definindo a latitude e a longitude da annotation
                    annotation.coordinate = item.placemark.coordinate
                    
                    //Definindo o titulo e subtitulo da annotation
                    annotation.title = item.name
                    annotation.subtitle = item.url?.absoluteString
                    
                    //Adicionando a annotation no mapa
                    self.mapView.addAnnotation(annotation)
                    
                }
            }
        }
    }
}

extension ViewController : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.lineWidth = 7.0
            renderer.strokeColor = .blue
            
            
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //Criando objeto de configuracao de requisicao de rota
        let request = MKDirectionsRequest()
        //Configurando a origem e o destino da rota
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: view.annotation!.coordinate))
        //Criando objeto que realiza o calculo da rota
        let directions = MKDirections(request: request)
        //Calcular a rota
        directions.calculate { (response, error) in
            if error == nil {
                guard let response = response else {return}
                //Recuperando a rota
                guard let route = response.routes.first else {return}
                //Nome da rota
                print(route.name)
                //Tempo estimado da rota
                print(route.expectedTravelTime)
                //Distancia da rota
                print(route.distance)
                for step in route.steps {
                    print ("Em", step.distance, "metros", step.instructions)
                }
                //Apagando rotas anteriores
                self.mapView.removeOverlays(self.mapView.overlays)
                //Adicionando o overlay da rota no mapa
                self.mapView.add(route.polyline, level: .aboveRoads)
            }
        }
        
    }
}

