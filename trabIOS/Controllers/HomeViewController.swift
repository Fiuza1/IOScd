import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let urlAPI = "https://5f8b39cf84531500167065f1.mockapi.io/"
    var id = Int()
    public var completionHandler: ((Int?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
    }
    
    private func callProductsService(with index: Int,
                                     result: @escaping([String:String]) -> ()){
        
        guard let url = URL(string: urlAPI + "product") else { return }
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
    
    @IBAction func didTapCell(_ sender: Any) {
        completionHandler?(id)
        
        let vc = storyboard?.instantiateViewController(identifier: "produtos")
        vc!.modalPresentationStyle = .fullScreen
        present(vc!, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        callProductsService(with: indexPath.row) { result in
            DispatchQueue.main.async {
                //retorno
                cell.textLabel?.text = "\(indexPath.row): \(String(describing: result["name"]))"
            }
        }
        return cell
    }
    
    
}
