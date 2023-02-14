import Foundation

public final class NetworkService {

    // MARK: - Init
    public init() {}
    
    static func fetchData(urlString: String, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(WeatherModel.self, from: data)
                completion(.success(result))
            } catch let error {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}
