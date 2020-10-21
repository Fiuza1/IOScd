import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtNome: UITextField!
    @IBOutlet weak var txtSenha: UITextField!
    let urlAPI = "https://5f8dbf474c15c40016a1e27e.mockapi.io/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func login(_ sender: Any) {
        guard let user = txtNome.text,
              let password = txtSenha.text else {
            
            return
        }
        
        callLoginService(with: user, and: password) { result in
            DispatchQueue.main.async {
                if result{
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                } else {
                    let alertController = UIAlertController(title: "Ops!", message: "Usuário ou Senha inválido!", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alertController, animated: true)
                }
            }
            
        }
        
    }
    
    private func callLoginService(with user:String, and password:String,
                                  completion: @escaping(Bool) -> ()){
        guard let url = URL(string: urlAPI + "Login") else { return }
        var urlRequest = URLRequest(url: url)
        
        let parameters = [ "name": user,
                           "senha": password ]
        
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
                    }
                    completion(true)
                } catch {
                    completion(false)
                }
            }
        }.resume()
    }

}
