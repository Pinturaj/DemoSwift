//
//  JokeViewController.swift
//  Fetch Jokes
//
//  Created by Pintu Rajput on 22/06/23.
//
import UIKit

class JokeViewController: UIViewController {
    @IBOutlet weak var jokesTableView: UITableView!
    
    let apiUrl = "https://geek-jokes.sameerkumar.website/api"
    let JOKESDATA = "jokesdata"

    var jokes: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        startJokeFetchingTimer()
    }
    
    func setupTableView() {
        jokesTableView.delegate = self
        jokesTableView.dataSource = self
        jokesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        if UserDefaults.standard.object(forKey: JOKESDATA) != nil {
            self.jokes  = UserDefaults.standard.object(forKey: JOKESDATA) as! [String];
            jokesTableView.reloadData()
        }else{
            fetchJoke()
        }
    }
    
    func fetchJoke() {
        guard let url = URL(string: apiUrl) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self,
                  let data = data,
                  let joke = String(data: data, encoding: .utf8) else { return }
            DispatchQueue.main.async {
                self.addJoke(joke)
            }
        }.resume()
    }
    
    func addJoke(_ joke: String) {
        jokes.append(joke)
        if jokes.count > 10 {
            jokes.removeFirst()
        }
        UserDefaults.standard.set(jokes, forKey: JOKESDATA)
        jokesTableView.reloadData()
    }
    
    func startJokeFetchingTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] (_) in
            self?.fetchJoke()
        }.fire()
    }
}

extension JokeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jokes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = jokes[indexPath.row]
        return cell
    }
}
