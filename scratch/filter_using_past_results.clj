(defn filter-using-past-results 
  ([predicate-fn candidates] (filter-using-past-results predicate-fn candidates []))
  ([predicate-fn candidates past-results]
   (if (empty? candidates)
     []
     (let [n (first candidates) remaining (rest candidates)]
       (if (predicate-fn n past-results)
         (cons n (lazy-seq (filter-using-past-results predicate-fn
                                                      remaining
                                                      (conj past-results n))))
         (lazy-seq (filter-using-past-results predicate-fn remaining past-results)))))))

(def player-pool [{:name "Sadie"   :position "center"}
                  {:name "Finn"    :position "forward"}
                  {:name "Sally"   :position "forward"}
                  {:name "Buster"  :position "center"}
                  {:name "Lachlan" :position "point-guard"}])

(defn should-pick? [player existing-team]
  (if (>= (count existing-team) 3)
    false
    (if (some #{(:position player)} (map :position existing-team))
      false
      true)))

(defn pick-team [pool] (filter-using-past-results should-pick? pool))

( pick-team player-pool )
