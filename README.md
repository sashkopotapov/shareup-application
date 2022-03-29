# iOS Engineering Challenge

<img src="https://res.craft.do/user/full/d7ce0db3-3096-bf97-e0e4-71b048d8674f/doc/81B22530-7446-4D43-B154-92CBEA68BCD2/78225F22-3B68-483D-B493-54BD514D3976_2/DmkmXx4n1AJn4E00EbNKwyccMtRP08ThXddg1PtOsScz/IMG_2D6A85CAA39E-1.jpeg" alt="Screenshot of Wordle" style="height:446px" height="446">

# Description

At Shareup, we love to play [Wordle](https://www.nytimes.com/games/wordle/). We have a channel in our company Discord dedicated to sharing our Wordle scores each day.

Although we love Wordle, we wish there was a way to look back at our previous performances to see how well we did and compare them with others.

Your challenge will be to create an iPhone app to list and display previous Wordle scores in an attractive and interesting way. The design should be inspired by Wordle’s native way of showing a person’s score without revealing the actual word or the guesses a person made. Wordle does this by creating something that looks like this:

> Wordle 281 4/6
> 
> ⬛⬛⬛⬛🟨<br>
> 🟨⬛🟨⬛⬛<br>
> ⬛⬛⬛🟨⬛<br>
> 🟩🟩🟩🟩🟩

_The above score was for the word “nymph”. The guesses were “train”, “ponds”, “blume”, and “nymph”._

# Requirements

The app needs to:

- **Be written in Swift**
- **Use `UIKit`** _(not `SwiftUI`)_
- Hide the actual word and guesses until the user taps on the cell.
- Show the word and guesses when the user taps on the cell.
- Feel pleasant to use through the use of high-quality animations and transitions

# Goals

In creating this challenge, **we are trying to assess your proficiency at building high-quality, interactive user interfaces using `UIKit`**. Although the basic requirements of this challenge are simple, we’re interested to see how you choose to design the initial “word hidden" view and how you transition from that to the "word shown" view.

We understand that you aren’t designers. So, we’re not looking for stunningly beautiful graphics or illustrations. Rather, we would like you to focus on building an experience that feels pleasant to use by displaying information cleanly and making use of animations and transitions.

# Starting point

We’ve put together a basic iPhone app that is capable of fetching scores from the server, decoding them into the local model, and displaying them in a modern `UICollectionView`. Additionally, we’ve written a basic algorithm to transform a guess into the Wordle tiles (e.g., from “ponds” to “🟨⬛🟨⬛⬛”). The views include Xcode Previews to enable quick prototyping, and the model layer is tested.

---

### Wordle Scores API

We’ve built an API you can use to fetch Wordle scores. It's not necessary to use this API inside of your app because we've supplied a mock, but we may use it in the follow-up interview. So, you may want to test it out.

In order to access the API, you’ll need to include an `Authorization` header with your personal access token, which you'll receive in an email.

Although the Wordle Scores API supports creating and deleting scores, those APIs are mostly available to aid you in developing and debugging your app. You should only need to use the “List scores” API inside of your app.

### List scores

```other
curl -XGET -H'X-Authorization: ACCESS_TOKEN' https://wordle.shareup.fun/scores
```

### Get a single score

```other
curl -XGET -H'X-Authorization: ACCESS_TOKEN' https://wordle.shareup.fun/scores/{id}
```

### Create a new score

```other
curl -XPOST -H'X-Authorization: ACCESS_TOKEN' -H'Content-Type: application/json' -d'{"id": 262, "date": "2022-03-08", "word": "sweet", "tries": ["corgi", "pause", "sleds", "sweet"]}' https://wordle.shareup.fun/scores
```

### Delete all scores

```other
curl -XDELETE -H'X-Authorization: ACCESS_TOKEN' https://wordle.shareup.fun/scores
```

This call actually resets your account’s scores to the initial state, which means your account will have three scores in it after this call completes.

### Delete a single score

```other
curl -XDELETE -H'X-Authorization: ACCESS_TOKEN' https://wordle.shareup.fun/scores/{id}
```

### Responses

Depending on the request, you'll either get back a JSON object or an array of JSON objects. In either case, the core type you'll receive back is a `score`, which has the following shape:

```json
{
  "id": 262,
  "date": "2022-03-08",
  "word": "sweet",
  "tries": ["corgi", "pause", "sleds", "sweet"]
}
```

In the case of an error, you may or may not receive a JSON object with an `error` key explaining the problem.

```json
{ "error": "missing id" }
```

