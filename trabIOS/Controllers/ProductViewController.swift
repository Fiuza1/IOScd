import UIKit

class ProductViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameProduto: UILabel!
    @IBOutlet weak var priceProduto: UILabel!
    @IBOutlet weak var descriptionProduto: UILabel!
    
    let urlAPI = "https://5f8dbf474c15c40016a1e27e.mockapi.io/"
    var idProduto = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = storyboard?.instantiateViewController(identifier: "home") as? HomeViewController
        vc?.completionHandler = { id in
            guard let id = id  else { return }
            self.idProduto = id
        }
        callProductsService(with: idProduto) { result in
            DispatchQueue.main.async {
                //retorno
                self.nameProduto.text = result["Nome"]
                self.descriptionProduto.text = result["descricao"]
                self.alteraImagem(imagem: result["img"] ?? "")
                self.priceProduto.text = "R$ \(String(describing: result["preco"]))"
            }
        }
    }

    private func callProductsService(with index: Int,
                                     result: @escaping([String:String]) -> ()){
        
        guard let url = URL(string: urlAPI + "Produtos") else { return }
        var urlRequest = URLRequest(url: url)
        
        let parameters = [ "id": index ]
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "content-type")
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            urlRequest.httpBody = jsonData
        } catch {
            print("erro de parse")
        }
        
        urlRequest.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let data = data {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String]
                    if let json = json{
                        print(json)
                        result(json)
                    }
                } catch {
                    let alertController = UIAlertController(title: "Ops!", message: "Não foi possivel recuperar os produtos!", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alertController, animated: true)
                }
            }
        }.resume()
    }
   
    private func alteraImagem(imagem: String){
        guard let urlImagem = URL(string: imagem) else { return }
        URLSession.shared.dataTask(with: urlImagem) { (data, response, error) in
            let imagem = UIImage(data: data!)
            DispatchQueue.main.async {
                self.image.image = imagem
            }
        }.resume()
    }
}
