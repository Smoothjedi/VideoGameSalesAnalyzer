#lang racket/base

(require csv-reading racket/match racket/string
         racket/list data/maybe string-interpolation)

(define filename
  "Video Games Sales.csv")

(define title-option "1. Title")
(define region-option "2. Region")
(define year-option "3. Year")
(define genre-option "4. Genre")
(define publisher-option "5. Publisher")
(define no-more-filters-option "6. No more filters")
(define rating-sort-option "1. Rating")
(define rank-sort-option "2. Rank")
(define north-america-region-option "1. North America")
(define europe-region-option "2. Europe")
(define japan-region-option "3. Japan")
(define rest-of-world-region-option "4. Rest of World")
(define global-region-option "5. Global")

(define restart-question "Would you like to analyze the data again?")
(define restart-option "1. Analyze again")
(define restart-exit "Any other input will exit!")
(define (display-choice-error choice)
  (displayln "Sorry, @{choice} is not a valid choice.")
  )
(define (display-welcome)
  (displayln "Welcome to the Game Sales Analyzer!"))
(define (display-counter-instruction submission-count)
  (displayln "Please make a selection.")
  (displayln "You have up to @{(- 3 submission-count)} left."))

;; prints every item in a list
(define (displayln-each lst)
  (for-each displayln lst))

(define sort-options
  (list rating-sort-option rank-sort-option))

(define menu-options
  (list title-option
        region-option
        year-option
        genre-option
        publisher-option
        no-more-filters-option))

(define region-options
  (list north-america-region-option
        europe-region-option
        japan-region-option
        rest-of-world-region-option
        global-region-option))

(define restart-options
  (list restart-option))

(define (csvfile->list filename)
  (call-with-input-file filename
    csv->list))

(define in-port
  (open-input-file "Video Games Sales.csv"))

(struct game-data
  (rank title platform year genre publisher
        north-america europe japan rest-of-world global review)
  #:transparent)

;; Defines how a line from the CSV should be converted to a game-data struct
(define (create-game-data line)
  (match line
    [(list index rank title platform year genre publisher
           north-america europe japan rest-of-world global review)
     (game-data
      ;; skips index
      (string->number rank)
      title
      platform
      (string->number year)
      genre
      publisher
      (string->number north-america)
      (string->number europe)
      (string->number japan)
      (string->number rest-of-world)
      (string->number global)
      (string->number review))]
    [_ (error "Failed to load record")]))

;; Converts a list of lines into game-data structs
(define (create-game-data-list)
  (let ([lines (csvfile->list filename)])
    ;; ignore the first line
    (map create-game-data (rest lines))))

;; The label for a generated list of structs from the file
(define game-data-list (create-game-data-list))

;; Cluster of lambda functions that will zero out categories not selected
(define (filter-region-na)
  (lambda (x)(struct-copy
              game-data x
              [europe 0]
              [japan 0]
              [rest-of-world 0]
              [global 0])))
(define (filter-region-europe)
  (lambda (x)(struct-copy
              game-data x
              [north-america 0]
              [japan 0]
              [rest-of-world 0]
              [global 0])))
(define (filter-region-japan)
  (lambda (x)(struct-copy
              game-data x
              [north-america 0]
              [europe 0]
              [rest-of-world 0]
              [global 0])))
(define (filter-region-row)
  (lambda (x)(struct-copy
              game-data x
              [north-america 0]
              [europe 0]
              [japan 0]
              [global 0])))
(define (filter-region-global)
  (lambda (x)(struct-copy
              game-data x
              [north-america 0]
              [europe 0]
              [japan 0]
              [rest-of-world 0])))

;; Accepts a lambda corresponding to a selected region and applies it
(define (filter-region region-to-filter lst)
  (map (region-to-filter) lst))

;; A cluster of filters and their lambdas
(define (filter-not-string=? value)
  (lambda(x) (not (string=? x value))))
(define (filter-string=? value)
  (lambda(x) (string=? x value)))
(define (filter-publisher publisher)
  (lambda(x) (string-contains?
              (string-downcase(game-data-publisher x))
              (string-downcase publisher))))
(define (filter-title title)
  (lambda(x) (string-ci=? (game-data-title x) title)))
(define (filter-platform platform)
  (lambda(x) (string-ci=? (game-data-platform x) platform)))
(define (filter-genre genre)
  (lambda(x) (string-ci=? (game-data-genre x) genre)))
(define (greater-than-year value)
  (lambda(x) (>= (game-data-year x) value)))
(define (less-than-year value)
  (lambda(x) (<= (game-data-year x) value)))
(define (greater-than-filter value lst)
  (filter (greater-than-year value) lst))
(define (less-than-filter value lst)
  (filter (less-than-year value) lst))
(define (filter-menu-choice-exists item)
  (lambda(x) (= (string->number (substring x 0 1)) item)))

;; Reads data, and returns nothing if it doesn't match a menu option
(define (read-menu-option available-options)
  (let ([input (read)])
    (if (and (integer? input)
             (not (empty?
                   (filter
                    (filter-menu-choice-exists input)
                    available-options))))        
        (just input)
        nothing)))

;; Reads data, and sends nothing if not a string
(define (read-string)
  (let ([input (read)])
    (if (string? input)
        (just input)
        nothing)))

;; Parses the year range from a string
(define (parse-years input)
  (map string->number
             (map string-trim
                  (string-split input "-"))))

;; Sorts the years in ascending order
(define (sort-years input)
  (sort (parse-years input) < ))

;; Filters list based on year range
(define (filter-years initial-data data-list)
  (let ([year-list (sort-years initial-data)])
    (filter (less-than-year (second year-list))
            (filter (greater-than-year (first year-list)) data-list))))

;; Takes a selection and compares it to the numbered menu options
;; If there are no results, option was invalid
(define (empty-menu-option? selected-option remaining-menu-options)
  (empty? (filter (filter-string=? selected-option) remaining-menu-options)))

(define (menu-loop remaining-menu-options submission-count filtered-list)
  ;; subfunction for collecting title and sorting the list
  (define (title-choice)
    (displayln "Please enter your title: ")
    (let ([input (read-string)])
      (cond [(nothing? input)
             (displayln "Invalid input.")
             (title-choice)]
            [else
             (let ([title (from-just! input)])
               (menu-loop
                (filter
                 (filter-not-string=? title-option)
                 remaining-menu-options)
                (+ submission-count 1)
                (filter
                 (filter-title title)
                 filtered-list)
                ))
             ])))
    (define (region)
    (displayln "Which region?")
    (displayln-each region-options)
    (let ([input (read-menu-option region-options)])
      (cond [(nothing? input)
             (displayln "Sorry, that is not a valid option.")
             (region)]
            [else
             ;; input guaranteed to be a number; use from-just!
             (let ([region-choice (from-just! input)])             
               (cond [(= region-choice 1)
                      (menu-loop
                       (filter
                        (filter-not-string=? region-option)
                        remaining-menu-options)
                       (+ submission-count 1)                       
                       (filter-region filter-region-na filtered-list)
                       )]
                     [(= region-choice 2)
                      (menu-loop
                       (filter
                        (filter-not-string=? region-option)
                        remaining-menu-options)
                       (+ submission-count 1)                       
                       (filter-region filter-region-europe filtered-list)
                       )]
                     [(= region-choice 3)
                      (menu-loop
                       (filter
                        (filter-not-string=? region-option)
                        remaining-menu-options)
                       (+ submission-count 1)                       
                       (filter-region filter-region-japan filtered-list)
                       )]
                     [(= region-choice 4)
                      (menu-loop
                       (filter
                        (filter-not-string=? region-option)
                        remaining-menu-options)
                       (+ submission-count 1)                       
                       (filter-region filter-region-row filtered-list)
                       )]
                     [(= region-choice 5)
                      (menu-loop
                       (filter
                        (filter-not-string=? region-option)
                        remaining-menu-options)
                       (+ submission-count 1)                       
                       (filter-region filter-region-global filtered-list)
                       )]
                     ))])))
  ;; subfunction for collecting years and sorting the list
  (define (year-choice)
    (displayln "Please enter the year range (i.e. \"2001 - 2004\": ")
    (let ([input (read-string)])
      (cond [(nothing? input)
             (displayln "Invalid input.")
             (year-choice)]
            [else
             (let ([years (from-just! input)])
               (menu-loop
                (filter
                 (filter-not-string=? year-option)
                 remaining-menu-options)
                (+ submission-count 1)
                (filter-years years filtered-list)
                ))
             ])))
  ;; subfunction for collecting genre and sorting the list
  (define (genre-choice)
    (displayln "Please enter the genre: ")
    (let ([input (read-string)])
      (cond [(nothing? input)
             (displayln "Invalid input.")
             (genre-choice)]
            [else
             (let ([genre (from-just! input)])              
               (menu-loop
                (filter
                 (filter-not-string=? genre-option)
                 remaining-menu-options)
                (+ submission-count 1)
                (filter
                 (filter-genre genre)
                 filtered-list)
                ))])))
  ;; subfunction for collecting publisher and sorting the list
  (define (publisher-choice)
    (displayln "Please enter the genre: ")
    (let ([input (read-string)])
      (cond [(nothing? input)
             (displayln "Invalid input.")
             (publisher-choice)]
            [else
             (let ([publisher (from-just! input)])              
               (menu-loop
                (filter
                 (filter-not-string=? publisher-option)
                 remaining-menu-options)
                (+ submission-count 1)
                (filter
                 (filter-publisher publisher)
                 filtered-list)
                ))])))
  ;; Base Case: Return nothing if all results were eliminated
  (cond [(empty? filtered-list)
         (displayln "Your latest filter choice has eliminated all possible results.")
         nothing]
        [else (display-counter-instruction submission-count)
              ;; display available options, collect data
              (displayln-each remaining-menu-options)
              (displayln "You have made @{submission-count} choices so far.")
              ;; Base Case: If three options have been selected, exit
              (if (> submission-count 2)
                  filtered-list
                  (let ([input (read-menu-option remaining-menu-options)])
                    ;; if an invalid menu option was selected, start over
                    (cond [(nothing? input)
                           (displayln "Sorry, that is not a valid option")
                           (menu-loop remaining-menu-options submission-count filtered-list)]
                          [else
                           ;; input guaranteed to be a number; use from-just!
                           (let ([choice (from-just! input)])                    
                             (cond [(= choice 1)
                                    ;; Check to make sure the option selection wasn't already eliminated
                                    (cond [(empty-menu-option? title-option remaining-menu-options)
                                           (display-choice-error choice)
                                           (menu-loop remaining-menu-options submission-count filtered-list)
                                           ]
                                          ;; Call the title subfunction
                                          [else (title-choice)])
                                    ]
                                   [(= choice 2) ;; Perform action for Option 2
                                    ;; Check to make sure the option selection wasn't already eliminated
                                    (cond [(empty-menu-option? region-option remaining-menu-options)
                                           (display-choice-error choice)
                                           (menu-loop remaining-menu-options submission-count filtered-list)
                                           ]
                                          ;; Call the platform subfunction
                                          [else (region)]
                                          )]
                                   [(= choice 3) ;; Perform action for Option 3
                                    ;; Check to make sure the option selection wasn't already eliminated
                                    (cond [(empty-menu-option? year-option remaining-menu-options)
                                           (display-choice-error choice)
                                           (menu-loop remaining-menu-options submission-count filtered-list)
                                           ]
                                          ;; Call the year subfunction
                                          [else (year-choice)])
                                    ]
                                   [(= choice 4) ;; Perform action for Option 4
                                    ;; Check to make sure the option selection wasn't already eliminated
                                    (cond [(empty-menu-option? genre-option remaining-menu-options)
                                           (display-choice-error choice)
                                           (menu-loop remaining-menu-options submission-count filtered-list)
                                           ]
                                          ;; Call the genre subfunction
                                          [else (genre-choice)])
                                    ]
                                   [(= choice 5) ;; Perform action for Option 5
                                    ;; Check to make sure the option selection wasn't already eliminated
                                    (cond [(empty-menu-option? publisher-option remaining-menu-options)
                                           (display-choice-error choice)
                                           (menu-loop remaining-menu-options submission-count filtered-list)
                                           ]
                                          ;; Call the publisher subfunction
                                          [else (publisher-choice)])
                                    ]
                                   ;; Base Case: Return the current list
                                   [(= choice 6) 
                                    filtered-list]
                                   [else
                                    (display-choice-error choice)
                                    (menu-loop remaining-menu-options submission-count filtered-list)]
                                   ))])))]))

;; This sorts the data given by user selected fields 
(define (sort-results unsorted-results)
  ;; Request selected option and sorts by it.
  ;; If an invalid input was detected, ask again.
  (displayln "How would you like your results sorted?")
  (displayln-each sort-options)
  (let ([input (read-menu-option sort-options)])
    (cond [(nothing? input)
           (displayln "Sorry, that is not a valid option.")
           (sort-results unsorted-results)]
          [else
           (let ([sort-choice (from-just! input)])
             (cond
               [(= sort-choice 1)
                (sort unsorted-results > #:key game-data-review)]
               [(= sort-choice 2)
                (sort unsorted-results < #:key game-data-rank)]
               ))]
          )))

;; Recursively prints the data in the list, or an empty line if empty.
;; Will not print a category that was set to zero.
(define (print-game-data-list game-data-list)
  (cond
    [(empty? game-data-list) (displayln "")]
    [else
     (let ([game-data (first game-data-list)])
       (display "Rank: @{(game-data-rank game-data)} ")
       (display "Title: @{(game-data-title game-data)} ")
       (display "Platform: @{(game-data-platform game-data)} ")
       (display "Year: @{(game-data-year game-data)} ")
       (display "Genre: @{(game-data-genre game-data)} ")
       (display "Publisher: @{(game-data-publisher game-data)} ")
       (unless (= (game-data-north-america game-data) 0)
         (display "North America: @{(game-data-north-america game-data)} "))
       (unless (= (game-data-europe game-data) 0)
         (display "Europe: @{(game-data-europe game-data)} "))
       (unless (= (game-data-japan game-data) 0)
         (display "Japan: @{(game-data-japan game-data)} "))
       (unless (= (game-data-rest-of-world game-data) 0)
         (display "Rest of World: @{(game-data-rest-of-world game-data)} "))
       (unless (= (game-data-global game-data) 0)
         (display "Global: @{(game-data-global game-data)} "))
       (displayln "Rating: @{(game-data-review game-data)} ")

       (print-game-data-list
        (rest game-data-list)))])) ;; Recursively process the rest of the list

;; Gets filtered data from the original game data
;; If data is returned, proceed to sort it
;; Print the sorted data
(define (process-data)
  (let ([filtered-data (menu-loop menu-options 0 game-data-list)])
    (if (not (nothing? filtered-data))
        (let ([sorted-data (sort-results filtered-data)])
          (print-game-data-list sorted-data)
          )
        (displayln "There is nothing to sort!")))
  ;; Ask the user if they would like to restart.
  ;; Check the response to see if it matches an available option
  ;; If not, the user wants to exit
  (displayln restart-question)
  (displayln-each restart-options)
  (displayln restart-exit)
  (let ([input (read-menu-option restart-options)])
    (cond [(not (nothing? input))
           (process-data)]
          [else (displayln "Thank you for using the analyzer!")])))

;; Welcome only gets displayed once
(define (analyzer-start)
  (display-welcome)
  (process-data))

;; Starts the program
(analyzer-start) 